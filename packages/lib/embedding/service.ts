import "server-only";
import { openai } from "@ai-sdk/openai";
import { embed } from "ai";
import kmeans from "kmeans-ts";
import { z } from "zod";
import { TEmbedding, ZEmbedding } from "@formbricks/types/embedding";
import { env } from "../env";
import { validateInputs } from "../utils/validate";

export const generateEmbedding = async (input: string): Promise<TEmbedding> => {
  if (!env.OPENAI_API_KEY) {
    throw new Error("OPENAI_API_KEY is not set");
  }

  const response = await embed({
    model: openai.embedding("text-embedding-3-small"),
    value: input,
  });

  return response.embedding;
};

const ZEmbeddingObject = z.object({
  id: z.string(),
  embedding: ZEmbedding,
});

type TEmbeddingObject = z.infer<typeof ZEmbeddingObject>;

export const clusterEmbeddings = async (embeddings: TEmbeddingObject[], k: number) => {
  validateInputs([embeddings, z.array(ZEmbeddingObject)], [k, z.number()]);
  // Extract the embeddings
  const input_data: Array<Array<number>> = embeddings.map((e) => e.embedding);

  // Check if there are enough unique points to form the specified number of clusters
  const uniqueEmbeddings = Array.from(new Set(input_data.map((embedding) => JSON.stringify(embedding)))).map(
    (e) => JSON.parse(e)
  );
  if (uniqueEmbeddings.length < k) {
    throw new Error(
      `Not enough unique points to form ${k} clusters. Reduce the number of clusters or provide more unique points.`
    );
  }

  // Perform k-means clustering
  const kmeansResult = kmeans(input_data, k, "kmeans");

  // Map the results back to the original embeddings
  const clusters = kmeansResult.indexes.map((clusterIndex, i) => ({
    cluster: clusterIndex,
    id: embeddings[i].id,
    embedding: embeddings[i].embedding,
  }));

  return clusters;
};
