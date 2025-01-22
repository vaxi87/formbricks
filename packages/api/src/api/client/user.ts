import { type Result } from "@formbricks/types/error-handlers";
import { type ApiErrorResponse } from "@formbricks/types/errors";
import { makeRequest } from "../../utils/make-request";

export class UserAPI {
  private apiHost: string;
  private environmentId: string;

  constructor(apiHost: string, environmentId: string) {
    this.apiHost = apiHost;
    this.environmentId = environmentId;
  }

  async createOrUpdate(userUpdateInput: {
    userId: string;
    attributes?: Record<string, string>;
    language?: string;
  }): Promise<
    Result<
      {
        state: {
          userId: string | null;
          segments: string[];
          displays: { surveyId: string; createdAt: Date }[];
          responses: string[];
          lastDisplayAt: Date | null;
        };
        details?: Record<string, string>;
      },
      ApiErrorResponse
    >
  > {
    // transform all attributes to string if attributes are present into a new attributes copy
    const attributes: Record<string, string> = {};
    for (const key in userUpdateInput.attributes) {
      attributes[key] = String(userUpdateInput.attributes[key]);
    }

    return makeRequest(
      this.apiHost,
      `/api/v1/client/${this.environmentId}/update/contacts/${userUpdateInput.userId}`,
      "POST",
      { attributes, language: userUpdateInput.language }
    );
  }
}
