"use client";

import { ResponseFeed } from "@/app/(app)/environments/[environmentId]/(people)/people/[personId]/components/ResponsesFeed";
import * as Collapsible from "@radix-ui/react-collapsible";
import { SparklesIcon } from "lucide-react";
import type { Session } from "next-auth";
import { useState } from "react";
import { cn } from "@formbricks/lib/cn";
import { TEnvironment } from "@formbricks/types/environment";
import { TResponse } from "@formbricks/types/responses";
import { TSurvey } from "@formbricks/types/surveys";

interface Cluster {
  insight: {
    headline: string;
    description: string;
  } | null;
  examples: TResponse[];
}

interface InsightProps {
  cluster: Cluster;
  environment: TEnvironment;
  session: Session;
  surveys: TSurvey[];
}

export const Insight = ({ cluster, environment, session, surveys }: InsightProps) => {
  const [open, setOpen] = useState(false);

  return (
    <Collapsible.Root
      open={open}
      onOpenChange={setOpen}
      className={cn(
        open ? "" : "hover:bg-slate-50",
        "w-full space-y-2 rounded-lg border border-slate-300 bg-white"
      )}>
      <Collapsible.CollapsibleTrigger
        asChild
        className="h-full w-full cursor-pointer"
        id="howToSendCardTrigger">
        <div className="inline-flex px-4 py-4">
          <div className="flex items-center pl-2 pr-5">
            <SparklesIcon
              strokeWidth={3}
              className="h-7 w-7 rounded-full border border-green-300 bg-green-100 p-1.5 text-green-600"
            />
          </div>
          <div>
            <p className="font-semibold text-slate-800">{cluster.insight?.headline}</p>
            <p className="mt-1 text-sm text-slate-500">{cluster.insight?.description}</p>
          </div>
        </div>
      </Collapsible.CollapsibleTrigger>
      <Collapsible.CollapsibleContent>
        <div className="bg-slate-100 p-2">
          <ResponseFeed
            surveys={surveys}
            user={session.user}
            responses={cluster.examples}
            environment={environment}
            environmentTags={[]}
            attributeClasses={[]}
          />
        </div>
      </Collapsible.CollapsibleContent>
    </Collapsible.Root>
  );
};
