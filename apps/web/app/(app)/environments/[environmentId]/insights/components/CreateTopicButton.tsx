"use client";

import { createInsightsTopicAction } from "@/app/(app)/environments/[environmentId]/insights/actions";
import { Button } from "@formbricks/ui/Button";

interface CreateTopicButtonProps {
  environmentId: string;
}

export const CreateTopicButton = ({ environmentId }: CreateTopicButtonProps) => {
  const createTopic = async () => {
    await createInsightsTopicAction(environmentId, {
      name: "Employee XM",
      description: "Information about employees in the company.",
    });
    await createInsightsTopicAction(environmentId, {
      name: "Bug",
      description: "An error or issue happennig in the app.",
    });
    await createInsightsTopicAction(environmentId, {
      name: "Feature Request",
      description: "A user request for a new feature in the app.",
    });
    alert("Topics created");
  };
  return <Button onClick={createTopic}>Create topic</Button>;
};
