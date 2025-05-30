import {
  mockEnvironmentId,
  mockLanguage,
  mockLanguageId,
  mockLanguageInput,
  mockLanguageUpdate,
  mockProjectId,
  mockUpdatedLanguage,
} from "./__mocks__/data.mock";
import { Prisma } from "@prisma/client";
import { prismaMock } from "@formbricks/database/src/jestClient";
import { PrismaErrorType } from "@formbricks/database/types/error";
import { DatabaseError, ValidationError } from "@formbricks/types/errors";
import { createLanguage, deleteLanguage, updateLanguage } from "../service";

const testInputValidation = async (service: Function, ...args: any[]): Promise<void> => {
  test("it should throw a ValidationError if the inputs are invalid", async () => {
    await expect(service(...args)).rejects.toThrow(ValidationError);
  });
};

describe("Tests for createLanguage service", () => {
  describe("Happy Path", () => {
    test("Creates a new Language", async () => {
      prismaMock.language.create.mockResolvedValue(mockLanguage);

      const language = await createLanguage(mockProjectId, mockEnvironmentId, mockLanguageInput);
      expect(language).toEqual(mockLanguage);
    });
  });

  describe("Sad Path", () => {
    testInputValidation(createLanguage, "123");

    test("Throws DatabaseError on PrismaClientKnownRequestError occurrence", async () => {
      const mockErrorMessage = "Mock error message";
      const errToThrow = new Prisma.PrismaClientKnownRequestError(mockErrorMessage, {
        code: PrismaErrorType.UniqueConstraintViolation,
        clientVersion: "0.0.1",
      });

      prismaMock.language.create.mockRejectedValue(errToThrow);

      await expect(createLanguage(mockProjectId, mockEnvironmentId, mockLanguageInput)).rejects.toThrow(
        DatabaseError
      );
    });

    test("Throws a generic Error for other exceptions", async () => {
      const mockErrorMessage = "Mock error message";
      prismaMock.language.create.mockRejectedValue(new Error(mockErrorMessage));

      await expect(createLanguage(mockProjectId, mockEnvironmentId, mockLanguageInput)).rejects.toThrow(
        Error
      );
    });
  });
});

describe("Tests for updateLanguage Service", () => {
  describe("Happy Path", () => {
    test("Updates a language", async () => {
      prismaMock.language.update.mockResolvedValue(mockUpdatedLanguage);

      const language = await updateLanguage(mockEnvironmentId, mockLanguageId, mockLanguageUpdate);
      expect(language).toEqual(mockUpdatedLanguage);
    });
  });

  describe("Sad Path", () => {
    testInputValidation(updateLanguage, "123", "123");

    test("Throws DatabaseError on PrismaClientKnownRequestError", async () => {
      const mockErrorMessage = "Mock error message";
      const errToThrow = new Prisma.PrismaClientKnownRequestError(mockErrorMessage, {
        code: PrismaErrorType.UniqueConstraintViolation,
        clientVersion: "0.0.1",
      });

      prismaMock.language.update.mockRejectedValue(errToThrow);

      await expect(updateLanguage(mockEnvironmentId, mockLanguageId, mockLanguageUpdate)).rejects.toThrow(
        DatabaseError
      );
    });

    test("Throws a generic Error for other unexpected issues", async () => {
      const mockErrorMessage = "Mock error message";
      prismaMock.language.update.mockRejectedValue(new Error(mockErrorMessage));

      await expect(updateLanguage(mockEnvironmentId, mockLanguageId, mockLanguageUpdate)).rejects.toThrow(
        Error
      );
    });
  });
});

describe("Tests for deleteLanguage", () => {
  describe("Happy Path", () => {
    test("Deletes a Language", async () => {
      prismaMock.language.delete.mockResolvedValue(mockLanguage);

      const language = await deleteLanguage(mockLanguageId, mockProjectId);
      expect(language).toEqual(mockLanguage);
    });
  });
  describe("Sad Path", () => {
    testInputValidation(deleteLanguage, "123");

    test("Throws DatabaseError on PrismaClientKnownRequestError occurrence", async () => {
      const mockErrorMessage = "Mock error message";
      const errToThrow = new Prisma.PrismaClientKnownRequestError(mockErrorMessage, {
        code: PrismaErrorType.UniqueConstraintViolation,
        clientVersion: "0.0.1",
      });

      prismaMock.language.delete.mockRejectedValue(errToThrow);

      await expect(deleteLanguage(mockLanguageId, mockProjectId)).rejects.toThrow(DatabaseError);
    });

    test("Throws a generic Error for other exceptions", async () => {
      const mockErrorMessage = "Mock error message";
      prismaMock.language.delete.mockRejectedValue(new Error(mockErrorMessage));

      await expect(deleteLanguage(mockLanguageId, mockProjectId)).rejects.toThrow(Error);
    });
  });
});
