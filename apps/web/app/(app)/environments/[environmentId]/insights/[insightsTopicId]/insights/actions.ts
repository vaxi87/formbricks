"use server";

import { openai } from "@ai-sdk/openai";
import { generateObject } from "ai";
import { getServerSession } from "next-auth";
import { z } from "zod";
import {
  getInsightsTopic,
  getInsightsTopicClusters,
  getInsightsTopicEmbedding,
} from "@formbricks/ee/insights/lib/insightsTopic/service";
import { TCluster } from "@formbricks/ee/insights/types/insightsTopics";
import { authOptions } from "@formbricks/lib/authOptions";
import { clusterEmbeddings } from "@formbricks/lib/embedding/service";
import { hasUserEnvironmentAccess } from "@formbricks/lib/environment/auth";
import { getMembershipByUserIdOrganizationId } from "@formbricks/lib/membership/service";
import { getOrganizationByEnvironmentId } from "@formbricks/lib/organization/service";
import { findNearestEmbeddingObjects, getResponse } from "@formbricks/lib/response/service";
import { responseToText } from "@formbricks/lib/response/utils";
import { AuthenticationError, AuthorizationError, ResourceNotFoundError } from "@formbricks/types/errors";
import { TResponse } from "@formbricks/types/responses";

export const generateInsightsAction = async (environmentId: string, insightsTopicId: string) => {
  const session = await getServerSession(authOptions);

  if (!session?.user) {
    throw new AuthenticationError("Not authenticated");
  }

  const insightsTopic = await getInsightsTopic(insightsTopicId);
  if (!insightsTopic) {
    throw new ResourceNotFoundError("Insights topic", "Insights topic not found");
  }

  if (!hasUserEnvironmentAccess(session.user.id, environmentId)) {
    throw new AuthorizationError("Not authorized");
  }

  const organization = await getOrganizationByEnvironmentId(environmentId);
  const membership = organization
    ? await getMembershipByUserIdOrganizationId(session.user.id, organization.id)
    : null;

  if (!membership) {
    throw new AuthorizationError("Not authorized");
  }

  if (membership.role === "viewer") {
    throw new AuthorizationError("Not authorized");
  }

  const clusters = await getInsightsTopicClusters(environmentId, insightsTopicId);

  return clusters;
};
