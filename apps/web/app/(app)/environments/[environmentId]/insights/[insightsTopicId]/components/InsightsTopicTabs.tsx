import { getProductByEnvironmentId } from "@formbricks/lib/product/service";
import { TProductConfigChannel } from "@formbricks/types/product";
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
  let currentProductChannel: TProductConfigChannel = null;

  if (!loading && environmentId) {
    const product = await getProductByEnvironmentId(environmentId);

    if (!product) {
      throw new Error("Product not found");
    }

    currentProductChannel = product.config.channel ?? null;
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
