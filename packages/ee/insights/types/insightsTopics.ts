import z from "zod";
import { TResponse } from "@formbricks/types/responses";

export const ZInsightsTopic = z.object({
  id: z.string(),
  createdAt: z.date(),
  updatedAt: z.date(),
  name: z.string(),
  description: z.string(),
  environmentId: z.string(),
});

export type TInsightsTopic = z.infer<typeof ZInsightsTopic>;

export const ZInsightsTopicCreateInput = z.object({
  name: z.string(),
  description: z.string(),
});

export type TInsightsTopicCreateInput = z.infer<typeof ZInsightsTopicCreateInput>;

export interface TCluster {
  insight: {
    headline?: string;
    description?: string;
  } | null;
  examples: TResponse[];
}
