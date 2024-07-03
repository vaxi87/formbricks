import { ResponseFeed } from "@/app/(app)/environments/[environmentId]/(people)/people/[personId]/components/ResponsesFeed";
import { getServerSession } from "next-auth";
import { getInsightsTopics } from "@formbricks/ee/insights/lib/insightsTopic/service";
import { authOptions } from "@formbricks/lib/authOptions";
import { getEnvironment } from "@formbricks/lib/environment/service";
import { getResponsesByEnvironmentId } from "@formbricks/lib/response/service";
import { getSurveys } from "@formbricks/lib/survey/service";
import { AuthenticationError } from "@formbricks/types/errors";
import { PageContentWrapper } from "@formbricks/ui/PageContentWrapper";
import { InsightsTopicNavigation } from "./components/InsightsTopicNavigation";

interface InsightsPageProps {
  params: {
    environmentId: string;
  };
}

const InsightsPage = async ({ params }: InsightsPageProps) => {
  const environment = await getEnvironment(params.environmentId);
  const insightsTopics = await getInsightsTopics(params.environmentId);
  const surveys = await getSurveys(params.environmentId);
  const session = await getServerSession(authOptions);
  const responses = await getResponsesByEnvironmentId(params.environmentId);

  if (!environment) {
    throw new Error("Environment not found");
  }

  if (!session?.user) {
    throw new AuthenticationError("Not authenticated");
  }

  return (
    <PageContentWrapper>
      <div className="flex space-x-10">
        <div className="flex w-60 flex-col">
          <InsightsTopicNavigation environmentId={params.environmentId} insightsTopics={insightsTopics} />
        </div>
        <div className="flex w-full flex-1 flex-col">
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
