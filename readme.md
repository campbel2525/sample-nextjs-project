# info

node のモノレポを使用しています

# 環境構築

### 手順 1

```
make cp-env
make init
```

### 手順 2

[http://localhost:3001/](http://localhost:3001/)にアクセスして

```
user1@example.com
test1
```

を入力してログインできれば OK

# メモ

## npm でインストールする際のコマンド例

```
npm install <ライブラリ名> -w user_front
```

# cicd の設定方法

## ブランチの想定運用

- stg ブランチ: ステージング環境
- prod ブランチ: 本番環境

## 設定方法

### 手順 1

AWS の App Runner の使用を想定しています。以下のリポジトリを apply してください。

- https://github.com/campbel2525/sample-apprunner-terraform

### 手順 2

コンソールに出力される

- user_front_apprunner_arn
- user_front_created_ecr_name
- user_front_github_actions_role
- region_id

を GitHub の Environments にそれぞれ

- user_front_apprunner_arn -> APPRUNNER_SERVICE_ARN
- user_front_created_ecr_name -> ECR_REPOSITORY_NAME
- user_front_github_actions_role -> IAM_ROLE_ARN
- region_id -> AWS_REGION

のようにセットしてください。

もしくは AWS のコンソールに入って適切に取得してください

### 手順 3

`apps/user_front/.env`を参考にして適切に ssm にセットしてください

### 手順 4

stg ブランチに push してください。Git Hub Action が実行されて cicd が実行されます

#

docker compose -f ./docker/local/docker-compose.yml -p sample-next-project build --no-cache

# 主要技術

- Next.js
- React
- TypeScript
- Prisma
- PostgreSQL
- Docker
- ESLint
- Prettier

# ディレクトリ構成

このリポジトリは、[Turborepo](https://turbo.build/repo)にインスパイアされたモノレポ構成を採用しています。

- `apps`: 各アプリケーションが格納されています。
  - `user_front`: Next.jsで構築されたフロントエンドアプリケーションです。
  - `scripts`: DBのマイグレーションやシード投入など、開発用のスクリプトが格納されています。
- `packages`: 複数のアプリケーションで共有されるパッケージが格納されています。
  - `db`: Prisma clientとスキーマ定義が格納されています。
  - `factories`: テストデータを作成するためのFactoryBotのような機能を提供します。
  - `seeders`: データベースに初期データを投入するためのシーダーが格納されています。
  - `tsconfig`: 共有のTypeScript設定が格納されています。
- `docker`: Docker関連の設定ファイルが格納されています。
  - `local`: ローカル開発環境用のDocker Composeファイルなどが格納されています。
  - `aws`: AWS App Runnerへのデプロイ用のDockerfileが格納されています。

# フォルダ構成

```
.
├── .gitignore
├── eslint.config.mjs
├── Makefile
├── package-lock.json
├── package.json
├── README.md
├── tsconfig.json
├── apps
│   ├── scripts
│   │   ├── .env.example
│   │   ├── .gitignore
│   │   ├── .prettierrc.json
│   │   ├── eslint.config.mjs
│   │   ├── package.json
│   │   ├── readme.md
│   │   ├── tsconfig.json
│   │   └── commands
│   │       └── run-seed.ts
│   └── user_front
│       ├── .gitignore
│       ├── .prettierrc.json
│       ├── eslint.config.mjs
│       ├── next.config.ts
│       ├── package.json
│       ├── postcss.config.mjs
│       ├── README.md
│       ├── tsconfig.json
│       ├── public
│       │   ├── file.svg
│       │   ├── globe.svg
│       │   ├── next.svg
│       │   ├── vercel.svg
│       │   └── window.svg
│       └── src
│           ├── app
│           │   ├── favicon.ico
│           │   ├── globals.css
│           │   ├── layout.tsx
│           │   ├── page.tsx
│           │   ├── api
│           │   │   └── auth
│           │   │       ├── [...nextauth]
│           │   │       ├── change-password
│           │   │       │   └── route.ts
│           │   │       └── update-profile
│           │   │           └── route.ts
│           │   ├── auth
│           │   │   ├── change-password
│           │   │   │   └── page.tsx
│           │   │   ├── edit-profile
│           │   │   │   └── page.tsx
│           │   │   ├── login
│           │   │   │   └── page.tsx
│           │   │   └── profile
│           │   │       └── page.tsx
│           │   ├── components
│           │   │   ├── LoginForm.tsx
│           │   │   └── SessionProvider.tsx
│           │   └── lib
│           │       ├── client
│           │       │   └── config.ts
│           │       ├── server
│           │       │   ├── auth.ts
│           │       │   └── config.ts
│           │       └── shared
│           │           ├── config.ts
│           │           └── utils.ts
│           └── types
│               ├── models.ts
│               ├── next-auth.d.ts
│               ├── requests.ts
│               └── responses.ts
├── docker
│   ├── aws
│   │   └── user_front
│   │       └── Dockerfile
│   └── local
│       ├── .env
│       ├── .env.example
│       ├── docker-compose.yml
│       ├── setup.dev.sql
│       ├── wait-for-db.sh
│       └── scripts
│           └── nodejs
│               └── Dockerfile
├── packages
│   ├── db
│   │   ├── client.ts
│   │   ├── package.json
│   │   └── prisma
│   │       ├── schema.prisma
│   │       └── migrations
│   │           ├── migration_lock.toml
│   │           └── 20250706141738_
│   │               └── migration.sql
│   ├── factories
│   │   ├── package.json
│   │   └── user_factory.ts
│   ├── seeders
│   │   ├── package.json
│   │   └── user_seeder.ts
│   └── tsconfig
│       └── base.json
```

# 便利なコマンド

`Makefile`に定義されている便利なコマンドです。

- `make up`: 開発環境を起動します。
- `make down`: 開発環境を停止します。
- `make reset`: データベースをリセットし、初期データを投入します。
- `make check`: コードのフォーマットと静的解析を実行します。
- `make user-front-shell`: `user_front`サービスのコンテナ内でシェルを起動します。
- `make scripts-shell`: `scripts`サービスのコンテナ内でシェルを起動します。

詳細は`Makefile`を参照してください。
`make help`でコマンドの一覧と説明を確認できます。
