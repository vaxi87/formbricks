import { z } from "zod";

export const ZEmbedding = z.array(z.number());

export type TEmbedding = z.infer<typeof ZEmbedding>;
