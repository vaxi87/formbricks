import "server-only";
import { env } from "../env";

export const generateEmbedding = async (input: string) => {
  if (!env.OPENAI_API_KEY) {
    throw new Error("OPENAI_API_KEY is not set");
  }

  // get embedding from open ai
  const res = await fetch("https://api.openai.com/v1/embeddings", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${env.OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      input,
      model: "text-embedding-3-small",
    }),
  });

  if (!res.ok) {
    console.error(res.status, res.statusText);
    throw new Error("Failed to get embedding");
  }

  const jsonResponse = await res.json();
  return jsonResponse.data[0].embedding;
};
