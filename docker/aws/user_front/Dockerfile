# --- ビルドステージ ---
# Next.js アプリケーションのビルドに必要な依存関係とビルドツールを含むベースイメージ
# public.ecr.aws/docker/library/node:22-bullseye は通常 amd64 (x64) アーキテクチャです。
FROM public.ecr.aws/docker/library/node:22-bullseye AS builder

# アプリケーションの作業ディレクトリを設定
WORKDIR /app

# npm/yarn のキャッシュを最適化するため、package.json とロックファイルを先にコピー
# モノレポのルートの package.json とロックファイルをコピーします
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Next.js アプリケーションと scripts ワークスペースの package.json をコピー
COPY apps/user_front/package.json apps/user_front/
COPY apps/scripts/package.json apps/scripts/

# Prisma スキーマとマイグレーションファイルをコピー
COPY packages/db/prisma/ ./packages/db/prisma/

# その他のソースコードをすべてコピー (依存関係インストール前に配置)
# これにより、npm install が実行される前に全てのファイルがコンテナ内に存在します。
COPY . .

# 環境変数を設定して、npm が特定のアーキテクチャ向けにネイティブモジュールをビルドするように強制します。
# node:22-bullseye は通常 amd64 (x64) アーキテクチャなので、'x64' と 'linux' を指定します。
ENV npm_config_arch=x64
ENV npm_config_platform=linux

# 依存関係をインストール (モノレポのルートでインストール)
# npm ci がロックファイルの同期問題で失敗するため、より柔軟な npm install --workspaces を使用します。
# プロダクションビルドでは npm ci が推奨されますが、ビルドの成功を優先します。
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; else npm install --workspaces; fi

# ネイティブモジュールを再ビルドして、正しいアーキテクチャのバイナリが確実にリンクされるようにします。
# これは lightningcss のような C++ バインディングを持つパッケージで特に役立ちます。
RUN npm rebuild

# Prisma Client を生成
# ルートの package.json に prisma.schema のパスが指定されているため、ルートで実行可能
RUN npx prisma generate

# Next.js アプリケーションをビルド
# next.config.js で output: "standalone" を設定している前提で、
# apps/user_front ワークスペースのビルドスクリプトを実行します
RUN npm run build --workspace apps/user_front

# --- プロダクションステージ ---
# 最終的なアプリケーションの実行環境、より軽量なイメージを使用
FROM public.ecr.aws/docker/library/node:22-bullseye-slim AS runner

# アプリケーションの実行ユーザーを作成 (セキュリティベストプラクティス)
# コンテナをrootユーザーで実行しないようにします
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# アプリケーションの作業ディレクトリを設定
WORKDIR /app

# Next.js のテレメトリを無効化 (任意)
ENV NEXT_TELEMETRY_DISABLED=1

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
COPY --from=builder /app/public ./public/
COPY --from=builder /app/.next/static ./.next/static/

# Prisma Client とマイグレーションファイルをコピー
# ビルドステージで /app/packages/db/prisma にコピーされた内容を、実行ステージの /app/prisma に配置します
COPY --from=builder /app/apps/scripts/prisma ./prisma/

# seed スクリプトとその依存関係 (ts-node, typescript) をコピー
# scripts ワークスペース全体をコピーします
COPY --from=builder /app/apps/scripts/ ./apps/scripts/
# packages/db も seed が依存しているのでコピー
COPY --from=builder /app/packages/db/ ./packages/db/
# packages/factories と packages/seeders も seed に必要なのでコピー
COPY --from=builder /app/packages/factories/ ./packages/factories/
COPY --from=builder /app/packages/seeders/ ./packages/seeders/

# tsconfig をコピー（ts-node 実行に必要）
# ルートの tsconfig.json と packages/tsconfig/ をコピーします。
COPY --from=builder /app/packages/tsconfig/ ./packages/tsconfig/
COPY --from=builder /app/tsconfig.json ./tsconfig.json

# seed スクリプトとその依存関係 (ts-node, typescript) をコピー
# scripts ワークスペース全体をコピーします
COPY --from=builder /app/apps/scripts/ ./apps/scripts/
# packages/db も seed が依存しているのでコピー
COPY --from=builder /app/packages/db/ ./packages/db/
# packages/factories と packages/seeders も seed に必要なのでコピー
COPY --from=builder /app/packages/factories/ ./packages/factories/
COPY --from=builder /app/packages/seeders/ ./packages/seeders/

# tsconfig をコピー（ts-node 実行に必要）
# ルートの tsconfig.json と packages/tsconfig/ をコピーします。
COPY --from=builder /app/packages/tsconfig/ ./packages/tsconfig/
COPY --from=builder /app/tsconfig.json ./tsconfig.json

# ビルド成果物をユーザーアプリとして配置
COPY --from=builder /app/apps/user_front/.next/standalone ./
COPY --from=builder /app/apps/user_front/public ./public/
COPY --from=builder /app/apps/user_front/.next/static ./.next/static/

# アプリケーションの起動コマンド
# ここでマイグレーションを実行し、その後 seed スクリプトを実行、最後にアプリケーションを起動します。
CMD ["sh", "-c", "npx prisma migrate deploy && npx ts-node apps/scripts/commands/run-seed.ts && node server.js"]
