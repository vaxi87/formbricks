"use client";

import { CreateInsightsTopicModal } from "@/app/(app)/environments/[environmentId]/insights/components/CreateInsightsTopicModal";
import clsx from "clsx";
import { PlusIcon } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { TInsightsTopic } from "@formbricks/ee/insights/types/insightsTopics";

interface InsightsTopicNavigationProps {
  insightsTopicId?: string;
  environmentId: string;
  insightsTopics: TInsightsTopic[];
}

export const InsightsTopicNavigation = ({
  environmentId,
  insightsTopicId,
  insightsTopics,
}: InsightsTopicNavigationProps) => {
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  return (
    <>
      <nav className="flex flex-1 flex-col" aria-label="Sidebar">
        <ul role="list" className="-mx-2 space-y-1">
          <li>
            <Link
              href={`/environments/${environmentId}/insights/`}
              className={clsx(
                !insightsTopicId
                  ? "bg-gray-50 text-teal-600"
                  : "text-gray-700 hover:bg-gray-50 hover:text-teal-600",
                "group flex gap-x-3 rounded-md p-2 pl-3 text-sm font-semibold leading-6"
              )}>
              📥 All Responses
            </Link>
          </li>
          <div className="h-5" />
          <div className="mb-2 flex justify-between border-b border-slate-200 pb-2">
            <h2 className="text-md font-semibold text-slate-800">Topics</h2>
            <button onClick={() => setIsCreateModalOpen(true)}>
              <PlusIcon className="h-6 w-6 text-slate-600" />
            </button>
          </div>
          {insightsTopics.map((item) => (
            <li key={item.name}>
              <Link
                href={`/environments/${environmentId}/insights/${item.id}`}
                className={clsx(
                  item.id === insightsTopicId
                    ? "bg-gray-50 text-teal-600"
                    : "text-gray-700 hover:bg-gray-50 hover:text-teal-600",
                  "group flex gap-x-3 rounded-md p-2 pl-3 text-sm font-semibold leading-6"
                )}>
                {item.name}
                {/* <span
                  className="ml-auto w-9 min-w-max whitespace-nowrap rounded-full bg-white px-2.5 py-0.5 text-center text-xs font-medium leading-5 text-gray-600 ring-1 ring-inset ring-gray-200"
                  aria-hidden="true">
                  25
                </span> */}
              </Link>
            </li>
          ))}
        </ul>
      </nav>
      <CreateInsightsTopicModal
        environmentId={environmentId}
        open={isCreateModalOpen}
        setOpen={setIsCreateModalOpen}
      />
    </>
  );
};
