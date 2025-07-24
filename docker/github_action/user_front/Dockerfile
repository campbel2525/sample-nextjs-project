# --- ビルドステージ ---
FROM public.ecr.aws/docker/library/node:22-bullseye AS builder
WORKDIR /app

# ルートの package.json とロックファイル
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# 各ワークスペースの package.json
COPY apps/user_front/package.json apps/user_front/
# （migration 用スクリプトはコピー不要なので省略）

# Prisma スキーマだけビルドに必要ならコピー
COPY packages/db/prisma/ ./packages/db/prisma/

# 残りのソース
COPY . .

# 依存関係インストール＆Prisma Client 生成
ENV npm_config_arch=x64
ENV npm_config_platform=linux
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; else npm install --workspaces; fi
RUN npm rebuild
RUN npx prisma generate

# Next.js アプリをビルド
RUN npm run build --workspace apps/user_front

# --- プロダクションステージ ---
FROM public.ecr.aws/docker/library/node:22-bullseye-slim AS runner

# 非 root ユーザー
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"
ENV PORT=3000
ENV NODE_ENV=production

# Next.js standalone ビルド成果物を正しく配置
COPY --from=builder --chown=nextjs:nodejs /app/apps/user_front/.next/standalone/ ./
COPY --from=builder --chown=nextjs:nodejs /app/apps/user_front/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/apps/user_front/.next/static ./.next/static

# Prisma Client が参照するスキーマファイル
COPY --from=builder --chown=nextjs:nodejs /app/packages/db/prisma ./prisma/

USER nextjs

EXPOSE 3000

# アプリケーション起動（standaloneビルドのserver.jsを直接実行）
CMD ["node", "server.js"]
