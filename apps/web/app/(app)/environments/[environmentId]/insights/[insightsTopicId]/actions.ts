"use server";

import { getServerSession } from "next-auth";
import { deleteInsightsTopic, getInsightsTopic } from "@formbricks/ee/insights/lib/insightsTopic/service";
import { authOptions } from "@formbricks/lib/authOptions";
import { hasUserEnvironmentAccess } from "@formbricks/lib/environment/auth";
import { getMembershipByUserIdOrganizationId } from "@formbricks/lib/membership/service";
import { getOrganizationByEnvironmentId } from "@formbricks/lib/organization/service";
import { AuthenticationError, AuthorizationError, ResourceNotFoundError } from "@formbricks/types/errors";

export const deleteInsightsTopicAction = async (id: string) => {
  const session = await getServerSession(authOptions);

  if (!session?.user) {
    throw new AuthenticationError("Not authenticated");
  }

  const insightsTopic = await getInsightsTopic(id);
  if (!insightsTopic) {
    throw new ResourceNotFoundError("Insights topic", "Insights topic not found");
  }

  const environmentId = insightsTopic.environmentId;

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

  await deleteInsightsTopic(insightsTopic.id);
};
