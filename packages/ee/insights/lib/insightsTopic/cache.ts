import { revalidateTag } from "next/cache";

interface RevalidateProps {
  id?: string;
  environmentId?: string;
}

export const insightsTopicCache = {
  tag: {
    byId(id: string): string {
      return `insightTopics-${id}`;
    },
    byEnvironmentId(environmentId: string): string {
      return `environments-${environmentId}-insightTopics`;
    },
  },
  revalidate({ id, environmentId }: RevalidateProps): void {
    if (id) {
      revalidateTag(this.tag.byId(id));
    }

    if (environmentId) {
      revalidateTag(this.tag.byEnvironmentId(environmentId));
    }
  },
};
