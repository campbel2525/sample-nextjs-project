# マイグレーション専用の軽量Dockerfile
FROM public.ecr.aws/docker/library/node:22-bullseye-slim

WORKDIR /app

# 必要なパッケージのみインストール
RUN apt-get update && apt-get install -y \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# 必要なpackage.jsonファイルをコピー
COPY packages/db/package.json ./packages/db/
COPY packages/db/prisma ./packages/db/prisma/

# ルートレベルでpackage.jsonを作成（依存関係管理用）
RUN echo '{"name": "migration-lambda", "version": "1.0.0", "dependencies": {"prisma": "latest", "@prisma/client": "latest"}}' > package.json

# 依存関係をインストール
RUN npm install prisma @prisma/client

# TypeScript関連の依存関係をインストール
RUN npm install -g typescript ts-node @types/node

# マイグレーションスクリプトをコピー
COPY apps/scripts/commands/run-migration.ts ./run-migration.ts

# Prismaクライアントを生成（ルートレベルで実行）
RUN npx prisma generate --schema=./packages/db/prisma/schema.prisma

# 環境変数を設定
ENV NODE_ENV=production
# ENV DATABASE_URL=""

# Lambda handler用のエントリーポイント（ts-nodeで直接実行）
CMD ["npx", "ts-node", "run-migration.ts"]
