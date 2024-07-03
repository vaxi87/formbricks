"use server";

import { getServerSession } from "next-auth";
import {
  createInsightsTopic,
  updateInsightsTopicEmbedding,
} from "@formbricks/ee/insights/lib/insightsTopic/service";
import { TInsightsTopicCreateInput } from "@formbricks/ee/insights/types/insightsTopics";
import { authOptions } from "@formbricks/lib/authOptions";
import { generateEmbedding } from "@formbricks/lib/embedding/service";
import { hasUserEnvironmentAccess } from "@formbricks/lib/environment/auth";
import { getEnvironment } from "@formbricks/lib/environment/service";
import { getMembershipByUserIdOrganizationId } from "@formbricks/lib/membership/service";
import { getOrganizationByEnvironmentId } from "@formbricks/lib/organization/service";
import { TEnvironment } from "@formbricks/types/environment";
import { AuthenticationError, AuthorizationError, ResourceNotFoundError } from "@formbricks/types/errors";

export const createInsightsTopicAction = async (
  environmentId: string,
  insightsTopicInput: TInsightsTopicCreateInput
) => {
  const session = await getServerSession(authOptions);

  if (!session?.user) {
    throw new AuthenticationError("Not authenticated");
  }

  // get the environment from service and check if the user is allowed to update the product
  let environment: TEnvironment | null = null;

  try {
    environment = await getEnvironment(environmentId);

    if (!environment) {
      throw new ResourceNotFoundError("Environment", "Environment not found");
    }
  } catch (err) {
    throw err;
  }

  if (!hasUserEnvironmentAccess(session.user.id, environment.id)) {
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
  const insightsTopic = await createInsightsTopic(environmentId, insightsTopicInput);
  const embedding = await generateEmbedding(`${insightsTopic.name}: ${insightsTopic.description}`);
  await updateInsightsTopicEmbedding(insightsTopic.id, embedding);
};
