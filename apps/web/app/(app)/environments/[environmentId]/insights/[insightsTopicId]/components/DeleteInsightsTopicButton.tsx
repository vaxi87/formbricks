"use client";

import { TrashIcon } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Button } from "@formbricks/ui/Button";
import { DeleteDialog } from "@formbricks/ui/DeleteDialog";
import { deleteInsightsTopicAction } from "../actions";

interface DeleteInsightsTopicButtonProps {
  insightsTopicId: string;
  environmentId: string;
}

export const DeleteInsightsTopicButton = ({
  insightsTopicId,
  environmentId,
}: DeleteInsightsTopicButtonProps) => {
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const router = useRouter();

  const deleteInsightsTopic = async () => {
    // Delete insights topic
    await deleteInsightsTopicAction(insightsTopicId);
    router.push(`/environments/${environmentId}/insights`);
  };
  return (
    <>
      <Button size="sm" onClick={() => setIsDeleteDialogOpen(true)} variant="minimal" target="_blank">
        <TrashIcon />
      </Button>

      <DeleteDialog
        open={isDeleteDialogOpen}
        setOpen={setIsDeleteDialogOpen}
        deleteWhat={"topic"}
        onDelete={deleteInsightsTopic}
      />
    </>
  );
};
