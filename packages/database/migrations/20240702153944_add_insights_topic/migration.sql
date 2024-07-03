-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "vector";

-- AlterTable
ALTER TABLE "Response" ADD COLUMN     "embedding" vector(1536);

-- CreateTable
CREATE TABLE "InsightsTopic" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "environmentId" TEXT NOT NULL,
    "embedding" vector(1536),

    CONSTRAINT "InsightsTopic_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "InsightsTopic" ADD CONSTRAINT "InsightsTopic_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES "Environment"("id") ON DELETE CASCADE ON UPDATE CASCADE;
