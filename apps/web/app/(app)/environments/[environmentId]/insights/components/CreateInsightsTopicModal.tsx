"use client";

import { createInsightsTopicAction } from "@/app/(app)/environments/[environmentId]/insights/actions";
import { zodResolver } from "@hookform/resolvers/zod";
import { BotIcon } from "lucide-react";
import { useRouter } from "next/navigation";
import { FormProvider, useForm } from "react-hook-form";
import {
  TInsightsTopicCreateInput,
  ZInsightsTopicCreateInput,
} from "@formbricks/ee/insights/types/insightsTopics";
import { Button } from "@formbricks/ui/Button";
import { FormControl, FormError, FormField, FormItem, FormLabel } from "@formbricks/ui/Form";
import { Input } from "@formbricks/ui/Input";
import { Modal } from "@formbricks/ui/Modal";
import { TextArea } from "@formbricks/ui/TextArea";

interface CreateInsightsTopicModalProps {
  environmentId: string;
  open: boolean;
  setOpen: (v: boolean) => void;
}

export const CreateInsightsTopicModal = ({ environmentId, open, setOpen }: CreateInsightsTopicModalProps) => {
  const router = useRouter();

  const form = useForm<TInsightsTopicCreateInput>({
    resolver: zodResolver(ZInsightsTopicCreateInput),
    mode: "onChange",
  });

  const createInsightsTopic = async (data: TInsightsTopicCreateInput) => {
    await createInsightsTopicAction(environmentId, data);
    setOpen(false);
    router.refresh();
  };

  const isSubmitting = form.formState.isSubmitting;

  return (
    <Modal open={open} setOpen={setOpen} noPadding>
      <div className="rounded-t-lg bg-slate-100">
        <div className="flex w-full items-center gap-4 p-6">
          <div className="flex items-center space-x-2">
            <div className="mr-1.5 h-6 w-6 text-slate-500">
              <BotIcon className="h-5 w-5" />
            </div>
            <div>
              <h3 className="text-base font-medium">Create Insights Topic</h3>
              <p className="text-sm text-slate-600">
                Sort your responses into your own categories to gain insights from your data.
              </p>
            </div>
          </div>
        </div>
      </div>
      <div className="w-full p-4">
        <FormProvider {...form}>
          <form className="w-full items-center space-y-2" onSubmit={form.handleSubmit(createInsightsTopic)}>
            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem>
                  <FormLabel htmlFor="name">Name</FormLabel>
                  <FormControl>
                    <Input type="text" id="name" {...field} placeholder="Name" autoComplete="off" required />
                  </FormControl>
                  <FormError />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel htmlFor="description">Description</FormLabel>
                  <FormControl>
                    <TextArea
                      id="description"
                      rows={6}
                      {...field}
                      placeholder="Description (min. 50 characters)"
                      autoComplete="off"
                      required
                    />
                  </FormControl>
                  <FormError />
                </FormItem>
              )}
            />

            <div className="flex justify-end pt-4">
              <div className="flex space-x-2">
                <Button
                  type="submit"
                  variant="darkCTA"
                  loading={isSubmitting}
                  disabled={isSubmitting}
                  className="mt-4">
                  Create
                </Button>
              </div>
            </div>
          </form>
        </FormProvider>
      </div>
    </Modal>
  );
};
