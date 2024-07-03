import "server-only";
import { Prisma } from "@prisma/client";
import { prisma } from "@formbricks/database";
import { cache } from "@formbricks/lib/cache";
import { validateInputs } from "@formbricks/lib/utils/validate";
import { ZId } from "@formbricks/types/environment";
import { DatabaseError } from "@formbricks/types/errors";
import {
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
