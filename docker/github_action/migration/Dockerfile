# マイグレーション専用の軽量Dockerfile
FROM public.ecr.aws/docker/library/node:22-bullseye-slim

WORKDIR /app

# 必要なパッケージのみインストール
RUN apt-get update && apt-get install -y \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# package.jsonをコピー（最小限の依存関係のみ）
COPY packages/db/package.json ./packages/db/
COPY packages/db/prisma ./packages/db/prisma/

# Prisma関連の依存関係のみインストール
RUN cd packages/db && npm install prisma @prisma/client

# マイグレーションスクリプトをコピー
COPY apps/scripts/commands/run-migration.ts ./run-migration.ts

# TypeScriptをJavaScriptにコンパイル
RUN npm install -g typescript ts-node
RUN tsc run-migration.ts --target es2020 --module commonjs --esModuleInterop --skipLibCheck

# Prismaクライアントを生成
RUN cd packages/db && npx prisma generate

# 環境変数を設定
ENV NODE_ENV=production
ENV DATABASE_URL=""

# Lambda handler用のエントリーポイント
CMD ["node", "run-migration.js"]
