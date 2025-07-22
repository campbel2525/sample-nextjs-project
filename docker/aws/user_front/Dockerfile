# --- ビルドステージ ---
FROM public.ecr.aws/docker/library/node:22-bullseye AS builder
WORKDIR /app

# ルートの package.json とロックファイル
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# 各ワークスペースの package.json
COPY apps/user_front/package.json apps/user_front/
COPY apps/scripts/package.json apps/scripts/

# Prisma スキーマ・マイグレーションファイル
COPY packages/db/prisma/ ./packages/db/prisma/

# 残りのソース
COPY . .

# ネイティブモジュール & Prisma Client
ENV npm_config_arch=x64
ENV npm_config_platform=linux
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; else npm install --workspaces; fi
RUN npm rebuild
RUN npx prisma generate

# Next.js のビルド
RUN npm run build --workspace apps/user_front

# --- プロダクションステージ ---
FROM public.ecr.aws/docker/library/node:22-bullseye-slim AS runner

# 非 root ユーザー設定
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"
ENV PORT=3000

# seed スクリプトと依存ファイル
COPY --from=builder /app/apps/scripts/ ./apps/scripts/
COPY --from=builder /app/packages/db/ ./packages/db/
COPY --from=builder /app/packages/factories/ ./packages/factories/
COPY --from=builder /app/packages/seeders/ ./packages/seeders/
COPY --from=builder /app/packages/tsconfig/ ./packages/tsconfig/
COPY --from=builder /app/tsconfig.json ./tsconfig.json

# Next.js ビルド成果物
COPY --from=builder /app/apps/user_front/.next/standalone ./
COPY --from=builder /app/apps/user_front/public ./public/
COPY --from=builder /app/apps/user_front/.next/static ./.next/static/

# アプリ起動とマイグレーション・シード
CMD ["sh", "-c", "npx prisma migrate deploy && npx ts-node apps/scripts/commands/run-seed.ts && node server.js"]
