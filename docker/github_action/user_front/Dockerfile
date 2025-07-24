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

# Prisma Client が参照するスキーマファイル
COPY --from=builder --chown=nextjs:nodejs /app/packages/db/prisma ./prisma/

# server.jsの場所を確認し、適切な場所に配置
RUN if [ -f "/app/apps/user_front/server.js" ]; then \
    echo "Found server.js in apps/user_front/"; \
    cp /app/apps/user_front/server.js /app/server.js; \
    elif [ -f "/app/server.js" ]; then \
    echo "server.js already in root"; \
    else \
    echo "server.js not found, creating fallback"; \
    echo 'const { createServer } = require("http"); const { parse } = require("url"); const next = require("next"); const dev = process.env.NODE_ENV !== "production"; const app = next({ dev }); const handle = app.getRequestHandler(); app.prepare().then(() => { createServer((req, res) => { const parsedUrl = parse(req.url, true); handle(req, res, parsedUrl); }).listen(3000, (err) => { if (err) throw err; console.log("> Ready on http://localhost:3000"); }); });' > /app/server.js; \
    fi

# ファイル構造を確認
RUN ls -la /app/
RUN cat /app/server.js | head -5

USER nextjs

EXPOSE 3000

# アプリケーション起動
CMD ["node", "server.js"]
