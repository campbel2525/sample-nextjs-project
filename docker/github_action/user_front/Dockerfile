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

# デバッグ: ビルド後のファイル構造を確認
RUN ls -la /app/apps/user_front/.next/
RUN ls -la /app/apps/user_front/.next/standalone/ || echo "standalone directory not found"
RUN find /app/apps/user_front/.next -name "server.js" -type f 2>/dev/null || echo "server.js not found in .next"

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

# .nextディレクトリ全体をコピー（ビルドIDなどの重要なファイルを含む）
COPY --from=builder --chown=nextjs:nodejs /app/apps/user_front/.next ./.next

# Prisma Client が参照するスキーマファイル
COPY --from=builder --chown=nextjs:nodejs /app/packages/db/prisma ./prisma/

# ファイル構造を確認
RUN ls -la /app/
RUN ls -la /app/.next/
RUN test -f /app/.next/BUILD_ID && echo "BUILD_ID found" || echo "BUILD_ID missing"

USER nextjs

EXPOSE 3000

# アプリケーション起動
CMD ["node", "server.js"]
