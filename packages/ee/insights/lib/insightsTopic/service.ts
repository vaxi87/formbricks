import "server-only";
import { openai } from "@ai-sdk/openai";
import { Prisma } from "@prisma/client";
import { generateObject } from "ai";
import { z } from "zod";
import { prisma } from "@formbricks/database";
import { cache } from "@formbricks/lib/cache";
import { clusterEmbeddings } from "@formbricks/lib/embedding/service";
import { responseCache } from "@formbricks/lib/response/cache";
import { findNearestEmbeddingObjects, getResponse } from "@formbricks/lib/response/service";
import { responseToText } from "@formbricks/lib/response/utils";
import { validateInputs } from "@formbricks/lib/utils/validate";
import { ZId } from "@formbricks/types/environment";
import { DatabaseError } from "@formbricks/types/errors";
import { TResponse } from "@formbricks/types/responses";
import {
  TCluster,
  TInsightsTopic,
  TInsightsTopicCreateInput,
  ZInsightsTopicCreateInput,
} from "../../types/insightsTopics";
import { insightsTopicCache } from "./cache";

const selectInsightsTopic = {
  id: true,
  createdAt: true,
  updatedAt: true,
  name: true,
  description: true,
  environmentId: true,
};

export const getInsightsTopics = (environmentId: string): Promise<TInsightsTopic[]> =>
  cache(
    async () => {
      validateInputs([environmentId, ZId]);

      try {
        return await prisma.insightsTopic.findMany({
          where: {
            environmentId,
          },
          select: selectInsightsTopic,
        });
      } catch (error) {
        if (error instanceof Prisma.PrismaClientKnownRequestError) {
          throw new DatabaseError(error.message);
        }

        throw error;
      }
    },
    [`getInsightsTopics-${environmentId}`],
    {
      tags: [insightsTopicCache.tag.byEnvironmentId(environmentId)],
    }
  )();

export const createInsightsTopic = async (
  environmentId: string,
  insightsTopicInput: TInsightsTopicCreateInput
): Promise<TInsightsTopic> => {
  validateInputs([environmentId, ZId], [insightsTopicInput, ZInsightsTopicCreateInput]);

  try {
    const insightsTopic = await prisma.insightsTopic.create({
      data: {
        environment: {
          connect: {
            id: environmentId,
          },
        },
        ...insightsTopicInput,
      },
      select: selectInsightsTopic,
    });

    insightsTopicCache.revalidate({
      id: insightsTopic.id,
      environmentId,
    });

    return insightsTopic;
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      throw new DatabaseError(error.message);
    }

    throw error;
  }
};

export const getInsightsTopic = (id: string): Promise<TInsightsTopic | null> =>
  cache(
    async () => {
      validateInputs([id, ZId]);

      try {
        return await prisma.insightsTopic.findUnique({
          where: {
            id,
          },
          select: selectInsightsTopic,
        });
      } catch (error) {
        if (error instanceof Prisma.PrismaClientKnownRequestError) {
          throw new DatabaseError(error.message);
        }

        throw error;
      }
    },
    [`getInsightsTopic-${id}`],
    {
      tags: [insightsTopicCache.tag.byId(id)],
    }
  )();

export const getInsightsTopicEmbedding = async (id: string): Promise<number[]> =>
  cache(
    async () => {
      validateInputs([id, ZId]);

      // Fetch the embedding from the database
      const result = await prisma.$queryRaw`
  SELECT "embedding"::text AS embedding
  FROM "InsightsTopic"
  WHERE "id" = ${id};
`;

      // Extract the embedding from the result
      const embeddingString = result[0]?.embedding;
      if (!embeddingString) {
        throw new Error(`No embedding found for id: ${id}`);
      }

      // Convert the string representation of the embedding back to an array of numbers
      const embeddingArray = embeddingString
        .slice(1, -1) // Remove the surrounding square brackets
        .split(",") // Split the string into an array of strings
        .map(Number); // Convert each string to a number

      return embeddingArray;
    },
    [`getInsightsTopicEmbedding-${id}`],
    {
      tags: [insightsTopicCache.tag.byId(id)],
    }
  )();

export const updateInsightsTopicEmbedding = async (id: string, embedding: number[]) => {
  // Convert the embedding array to a string representation that PostgreSQL understands
  const embeddingString = `[${embedding.join(",")}]`;

  await prisma.$executeRaw`
    UPDATE "InsightsTopic"
    SET "embedding" = ${embeddingString}::vector(1536)
    WHERE "id" = ${id};
  `;
};

export const findNearestInsightsTopic = async (
  environmentId: string,
  embedding: number[],
  limit: number = 5
) => {
  validateInputs([environmentId, ZId]);
  const threshold = 0.2;
  // Convert the embedding array to a JSON-like string representation
  const embeddingString = `[${embedding.join(",")}]`;

  // Execute raw SQL query to find nearest neighbors and exclude the vector column
  const nearestNeighborIds = await prisma.$queryRaw`
    SELECT id
    FROM "InsightsTopic"
    WHERE "environmentId" = ${environmentId}
      AND "embedding" <=> ${embeddingString}::vector(1536) <= ${threshold}
    ORDER BY "embedding" <=> ${embeddingString}::vector(1536)
    LIMIT ${limit};
  `;

  const insightsTopic = await getInsightsTopic(nearestNeighborIds[0].id);
  return insightsTopic;
};

export const deleteInsightsTopic = async (id: string): Promise<TInsightsTopic | null> => {
  validateInputs([id, ZId]);

  try {
    const insightsTopic = await prisma.insightsTopic.delete({
      where: {
        id,
      },
      select: selectInsightsTopic,
    });

    insightsTopicCache.revalidate({
      id: insightsTopic.id,
      environmentId: insightsTopic.environmentId,
    });

    return insightsTopic;
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      throw new DatabaseError(error.message);
    }

    throw error;
  }
};

export const getInsightsTopicClusters = async (environmentId: string, insightsTopicId: string) =>
  cache(
    async () => {
      const insightsTopic = await getInsightsTopic(insightsTopicId);
      // Get all embeddings from the insightsTopic reponses
      const insightsTopicEmbeddings = await getInsightsTopicEmbedding(insightsTopicId);
      const embeddingObjects = await findNearestEmbeddingObjects(environmentId, insightsTopicEmbeddings, 10);
      const clusteringOutput = await clusterEmbeddings(embeddingObjects, 3);

      const clusters: TCluster[] = [];

      // build a cluster object with two examples from each cluster
      for (let i = 0; i < 3; i++) {
        const exampleIds = clusteringOutput
          .filter((cluster) => cluster.cluster === i)
          .slice(0, 2)
          .map((cluster) => cluster.id);
        const responses = await Promise.all(exampleIds.map((id) => getResponse(id)));
        const filteredResponses = responses.filter((response) => response !== null) as TResponse[];
        clusters.push({ insight: null, examples: filteredResponses });
      }
      // generate insights for every cluster by an LLM
      for (const cluster of clusters) {
        // generate insights
        // generate examples for insights topic
        const { object } = await generateObject({
          model: openai("gpt-4-turbo"),
          schema: z.object({
            insight: z.object({
              headline: z.string(),
              description: z.string(),
            }),
          }),
          prompt: `I collected survey responses for the topic "${insightsTopic.name} (${insightsTopic.description})". Please summarize the following feedback in one sentence as a description and add a headline highlighting the key point: ${cluster.examples.map((example) => `"${responseToText(example)}"`).join(", ")}`,
        });

        cluster.insight = object.insight;
      }

      return clusters;
    },
    [`getInsightsTopicClusters-${environmentId}-${insightsTopicId}`],
    {
      tags: [insightsTopicCache.tag.byId(insightsTopicId), responseCache.tag.byEnvironmentId(environmentId)],
    }
  )();
