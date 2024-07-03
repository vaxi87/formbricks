import { ResponseFeed } from "@/app/(app)/environments/[environmentId]/(people)/people/[personId]/components/ResponsesFeed";
import { getServerSession } from "next-auth";
import {
  getInsightsTopic,
  getInsightsTopicEmbedding,
  getInsightsTopics,
} from "@formbricks/ee/insights/lib/insightsTopic/service";
import { authOptions } from "@formbricks/lib/authOptions";
import { getEnvironment } from "@formbricks/lib/environment/service";
import { findNearestResponses } from "@formbricks/lib/response/service";
import { getSurveys } from "@formbricks/lib/survey/service";
import { AuthenticationError } from "@formbricks/types/errors";
import { PageContentWrapper } from "@formbricks/ui/PageContentWrapper";
import { PageHeader } from "@formbricks/ui/PageHeader";
import { InsightsTopicNavigation } from "../components/InsightsTopicNavigation";
import { DeleteInsightsTopicButton } from "./components/DeleteInsightsTopicButton";

interface InsightsPageProps {
  params: {
    environmentId: string;
    insightsTopicId: string;
  };
}

const InsightsPage = async ({ params }: InsightsPageProps) => {
  const environment = await getEnvironment(params.environmentId);
  const insightsTopics = await getInsightsTopics(params.environmentId);
  const insightsTopic = await getInsightsTopic(params.insightsTopicId);
  const surveys = await getSurveys(params.environmentId);
  const session = await getServerSession(authOptions);

  if (!environment) {
    throw new Error("Environment not found");
  }

  if (!session?.user) {
    throw new AuthenticationError("Not authenticated");
  }

  if (!insightsTopic) {
    throw new Error("Insights topic not found");
  }

  const insightsTopicEmbedding = await getInsightsTopicEmbedding(params.insightsTopicId);
  const responses = await findNearestResponses(params.environmentId, insightsTopicEmbedding, 10);

  return (
    <PageContentWrapper>
      <div className="flex space-x-10">
        <div className="flex w-60 flex-col">
          <InsightsTopicNavigation
            environmentId={params.environmentId}
            insightsTopicId={params.insightsTopicId}
            insightsTopics={insightsTopics}
          />
        </div>
        <div className="flex w-full flex-1 flex-col">
          <PageHeader
            pageTitle={insightsTopic.name}
            cta={
              <DeleteInsightsTopicButton
                insightsTopicId={params.insightsTopicId}
                environmentId={params.environmentId}
              />
            }
          />
          <ResponseFeed
            surveys={surveys}
            user={session.user}
            responses={responses}
            environment={environment}
            environmentTags={[]}
            attributeClasses={[]}
          />
        </div>
      </div>
    </PageContentWrapper>
  );
};

export default InsightsPage;
