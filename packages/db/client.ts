// packages/db/client.ts (新しいファイル)
import { PrismaClient } from "@prisma/client";

declare global {
  // eslint-disable-next-line no-var
  var prisma: PrismaClient | undefined;
}

// グローバルにインスタンスを保持し、なければ生成する
export const prisma = globalThis.prisma || new PrismaClient();

// 開発環境では、グローバル変数を更新する
if (process.env.NODE_ENV !== "production") {
  globalThis.prisma = prisma;
}
