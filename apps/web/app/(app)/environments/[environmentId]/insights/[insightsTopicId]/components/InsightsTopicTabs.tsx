import { getProductByEnvironmentId } from "@formbricks/lib/product/service";
import { SecondaryNavigation } from "@formbricks/ui/SecondaryNavigation";

interface InsightsTopicSubnavigationProps {
  activeId: string;
  environmentId?: string;
  insightsTopicId?: string;
  loading?: boolean;
}

export const InsightsTopicTabs = async ({
  activeId,
  environmentId,
  insightsTopicId,
  loading,
}: InsightsTopicSubnavigationProps) => {
  if (!loading && environmentId) {
    const product = await getProductByEnvironmentId(environmentId);

    if (!product) {
      throw new Error("Product not found");
    }
  }

  const navigation = [
    {
      id: "responses",
      label: "Responses",
      href: `/environments/${environmentId}/insights/${insightsTopicId}/responses`,
    },
    {
      id: "insights",
      label: "Insights",
      href: `/environments/${environmentId}/insights/${insightsTopicId}/insights`,
    },
  ];

  return <SecondaryNavigation navigation={navigation} activeId={activeId} loading={loading} />;
};
