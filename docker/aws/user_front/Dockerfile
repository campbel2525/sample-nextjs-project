# --- ビルドステージ ---
# Next.js アプリケーションのビルドに必要な依存関係とビルドツールを含むベースイメージ
FROM public.ecr.aws/docker/library/node:22-bullseye AS builder

# アプリケーションの作業ディレクトリを設定
WORKDIR /app

# npm/yarn のキャッシュを最適化するため、package.json とロックファイルを先にコピー
# モノレポのルートの package.json とロックファイルをコピーします
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Next.js アプリケーションの package.json をコピー
COPY apps/user_front/package.json apps/user_front/

# Prisma スキーマとマイグレーションファイルをコピー
COPY packages/db/prisma/ ./packages/db/prisma/

# 依存関係をインストール (モノレポのルートでインストール)
# npm ci は package-lock.json を基に依存関係を厳密にインストールします
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; elif [ -f package-lock.json ]; then npm ci; else npm install; fi

# Prisma Client を生成
# ルートの package.json に prisma.schema のパスが指定されているため、ルートで実行可能
RUN npx prisma generate

# その他のソースコードをすべてコピー
COPY . .

# Next.js アプリケーションをビルド
# next.config.js で output: "standalone" を設定している前提で、
# apps/user_front ワークスペースのビルドスクリプトを実行します
RUN npm run build --workspace apps/user_front

# --- プロダクションステージ ---
# 最終的なアプリケーションの実行環境、より軽量なイメージを使用
FROM public.ecr.aws/docker/library/node:22-bullseye-slim AS runner

# アプリケーションの実行ユーザーを作成 (セキュリティベストプラクティス)
# コンテナを root ユーザーで実行しないようにします
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# アプリケーションの作業ディレクトリを設定
WORKDIR /app

# Next.js のテレメトリを無効化 (任意)
ENV NEXT_TELEMETRY_DISABLED 1

# Next.js がリッスンするホストとポートを設定
# HOSTNAME="0.0.0.0" は全てのネットワークインターフェースでリッスンすることを意味します
ENV HOSTNAME="0.0.0.0"
# App Runner のデフォルトポートに合わせるか、Next.js のデフォルトポート (3000) を使用
# App Runner サービス設定でポートを 8080 に設定する場合、Next.js の起動スクリプトが自動的に環境変数 PORT を読み取るため、
# この行の PORT=3000 は App Runner 設定で上書きされます。
# もし App Runner 側でポート指定をしない場合、Next.js はデフォルトの 3000 で起動します。
ENV PORT=3000

# ビルドステージから必要なファイルをコピー
# Next.js の standalone 出力を使用する場合
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./public
# 静的アセットをコピー
COPY --from=builder /app/.next/static ./.next/static
# Prisma Client とマイグレーションファイルをコピー
# ビルドステージで /app/packages/db/prisma にコピーされた内容を、実行ステージの /app/prisma に配置します
COPY --from=builder /app/packages/db/prisma ./prisma/


# アプリケーションの起動コマンド
# ここでマイグレーションを実行し、その後アプリケーションを起動します。
# `npx prisma migrate deploy` は、保留中のすべてのマイグレーションをデータベースに適用します。
# データベース接続に必要な環境変数 (DATABASE_URL) が App Runner の環境変数で設定されている必要があります。
# CMD ["sh", "-c", "npx prisma migrate deploy --schema=./prisma/schema.prisma && node server.js"]

# もし必要であれば、べき等（何回実行しても同じ結果になる）な seed スクリプトをマイグレーション後に実行できます。
CMD ["sh", "-c", "npx prisma migrate deploy --schema=./prisma/schema.prisma && npx ts-node apps/scripts/scripts/run-seed.ts && node server.js"]
# ただし、seed の実行には `ts-node` や `typescript` が必要になり、runner イメージを重くする可能性があります。
# 通常、seed は本番環境での自動デプロイでは実行せず、手動または別のジョブで行うのが一般的です。
