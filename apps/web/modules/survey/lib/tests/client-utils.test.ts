import { describe, expect, test } from "vitest";
import { copySurveyLink } from "../client-utils";

describe("copySurveyLink", () => {
  test("appends singleUseId when provided", () => {
    const surveyUrl = "http://example.com/survey";
    const singleUseId = "12345";
    const result = copySurveyLink(surveyUrl, singleUseId);
    expect(result).toBe("http://example.com/survey?suId=12345");
  });

  test("returns original surveyUrl when singleUseId is not provided", () => {
    const surveyUrl = "http://example.com/survey";
    const result = copySurveyLink(surveyUrl);
    expect(result).toBe(surveyUrl);
  });
});
