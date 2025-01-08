import { InsightCategory } from "@prisma/client";
import { z } from "zod";
import { ZId } from "../../types/common";
import { _InsightModel } from "../zod/insight";

export const ZInsight = _InsightModel.extend({
  _count: z.object({
    documentInsights: z.number(),
  }),
});

export type TInsight = z.infer<typeof ZInsight>;

export const ZInsightCreateInput = z.object({
  environmentId: ZId,
  title: z.string(),
  description: z.string(),
  category: z.nativeEnum(InsightCategory),
  vector: z.array(z.number()).length(512),
});

export type TInsightCreateInput = z.infer<typeof ZInsightCreateInput>;

export const ZInsightFilterCriteria = z.object({
  documentCreatedAt: z
    .object({
      min: z.date().optional(),
      max: z.date().optional(),
    })
    .optional(),
  category: z.nativeEnum(InsightCategory).optional(),
});

export type TInsightFilterCriteria = z.infer<typeof ZInsightFilterCriteria>;
