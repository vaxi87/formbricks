"use client";

import { generateInsightsAction } from "@/app/(app)/environments/[environmentId]/insights/[insightsTopicId]/insights/actions";
import { Insight } from "@/app/(app)/environments/[environmentId]/insights/[insightsTopicId]/insights/components/Insight";
import { SparkleIcon } from "lucide-react";
import type { Session } from "next-auth";
import { useState } from "react";
import { TEnvironment } from "@formbricks/types/environment";
import { TResponse } from "@formbricks/types/responses";
import { TSurvey } from "@formbricks/types/surveys";
import { Alert, AlertDescription, AlertTitle } from "@formbricks/ui/Alert";
import { Button } from "@formbricks/ui/Button";
import { LoadingSpinner } from "@formbricks/ui/LoadingSpinner";

interface InsightsCardProps {
  surveys: TSurvey[];
  environment: TEnvironment;
  insightsTopicId: string;
  session: Session;
}

interface Cluster {
  insight: {
    headline: string;
    description: string;
  } | null;
  examples: TResponse[];
}

export const InsightsCard = ({ environment, session, insightsTopicId, surveys }: InsightsCardProps) => {
  const [insights, setInsights] = useState<Cluster[]>([]);
  const [loading, setLoading] = useState(false);

  const generateInsights = async () => {
    setLoading(true);
    const insights = await generateInsightsAction(environment.id, insightsTopicId);
    setInsights(insights);
    setLoading(false);
  };

  return (
    <div className="mt-4 overflow-hidden rounded-lg bg-white shadow">
      <div className="border-b border-gray-200 bg-white px-4 py-5 sm:px-6">
        <div className="-ml-4 -mt-2 flex flex-wrap items-center justify-between sm:flex-nowrap">
          <div className="ml-4 mt-2">
            <h3 className="text-base font-semibold leading-6 text-gray-900">Insights</h3>
          </div>
          <div className="ml-4 mt-2 flex-shrink-0">
            <Button
              StartIcon={SparkleIcon}
              onClick={() => {
                generateInsights();
              }}
              variant="darkCTA"
              size="sm">
              Regenerate
            </Button>
          </div>
        </div>
      </div>
      <div className="p-3 text-sm">
        {loading ? (
          <LoadingSpinner />
        ) : insights.length === 0 ? (
          <Alert variant="info">
            <AlertTitle>No Insights found</AlertTitle>
            <AlertDescription>Please wait for more responses or regenerate</AlertDescription>
          </Alert>
        ) : (
          <div className="flex flex-col space-y-4">
            {insights.map((insight, index) => (
              <Insight
                key={index}
                cluster={insight}
                environment={environment}
                session={session}
                surveys={surveys}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
