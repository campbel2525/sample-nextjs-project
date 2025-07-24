# Sample Next.js Monorepo Project

このプロジェクトは、Next.js と Prisma を使用したモノレポ構成のサンプルです。
開発環境は Docker で構築されており、`make`コマンドで簡単に操作できます。

## 主要技術

- **Frontend**: Next.js, React, TypeScript
- **Backend**: Next.js (API Routes)
- **ORM**: Prisma
- **Database**: MySQL
- **Container**: Docker, Docker Compose
- **CI/CD**: GitHub Actions, AWS App Runner
- **Lint/Format**: ESLint, Prettier

## ローカル開発環境のセットアップ

1.  **環境変数の設定**

    リポジトリのルートディレクトリで以下のコマンドを実行し、環境変数のサンプルファイルをコピーします。

    ```bash
    make cp-env
    ```

2.  **開発環境の構築と起動**

    以下のコマンドを実行すると、Docker コンテナのビルド、データベースのセットアップ、依存パッケージのインストールが自動的に行われます。

    ```bash
    make init
    ```

3.  **動作確認**

    セットアップが完了したら、ブラウザで [http://localhost:3001](http://localhost:3001) にアクセスしてください。
    以下の情報でログインできれば、環境構築は成功です。

    - **Email**: `user1@example.com`
    - **Password**: `test1`

## 便利なコマンド (Makefile)

このプロジェクトでは、煩雑な`docker compose`コマンドをラップした`make`コマンドを提供しています。

| コマンド                | 説明                                                                 |
| ----------------------- | -------------------------------------------------------------------- |
| `make help`             | 利用可能なすべてのコマンドとその説明を表示します。                   |
| `make up`               | 開発環境（Docker コンテナ）を起動します。                            |
| `make down`             | 開発環境を停止します。                                               |
| `make reset`            | データベースをリセットし、初期データを再投入します。                 |
| `make check`            | すべてのワークスペースでコードのフォーマットと静的解析を実行します。 |
| `make user-front-shell` | フロントエンド (`user_front`) のコンテナ内でシェルを起動します。     |
| `make scripts-shell`    | スクリプト (`scripts`) 用のコンテナ内でシェルを起動します。          |

その他のコマンドについては`Makefile`を参照するか、`make help`を実行してください。

### パッケージのインストール

特定のワークスペースにライブラリを追加する場合は、`-w`オプションを使用します。

```bash
# 例: user_front ワークスペースにライブラリをインストール
npm install <ライブラリ名> -w user_front
```

## ディレクトリ構成

このリポジトリは、npm workspaces を利用したモノレポ構成を採用しています。

- `apps`: 各アプリケーションが格納されています。
  - `user_front`: Next.js で構築されたフロントエンドアプリケーションです。
  - `scripts`: DB のマイグレーションやシード投入など、開発用のスクリプトが格納されています。
- `packages`: 複数のアプリケーションで共有されるパッケージが格納されています。
  - `db`: Prisma client、スキーマ定義、マイグレーションファイルが格納されています。
  - `factories`: テストデータを作成するための FactoryBot のような機能を提供します。
  - `seeders`: データベースに初期データを投入するためのシーダーが格納されています。
  - `tsconfig`: 共有の TypeScript 設定が格納されています。
- `docker`: Docker 関連の設定ファイルが格納されています。
  - `local`: ローカル開発環境用の Docker Compose ファイルなどが格納されています。
  - `aws`: AWS App Runner へのデプロイ用の Dockerfile が格納されています。

```
.
├── apps
│   ├── scripts
│   └── user_front
├── packages
│   ├── db
│   │   └── prisma
│   │       └── migrations
│   ├── factories
│   ├── seeders
│   └── tsconfig
├── docker
│   ├── aws
│   └── local
├── .github/workflows
│   └── cicd.yml
├── Makefile
├── package.json
└── README.md
```

## CI/CD

GitHub Actions を利用して、特定のブランチへのプッシュをトリガーに AWS App Runner へ自動デプロイされます。

### ブランチ戦略

開発は`main`ブランチをベースに行います。各環境へのデプロイフローは以下の通りです。

- **`main`**: 開発ブランチ。このブランチへのマージが開発の基本となります。
- **`stg`**: ステージング環境用ブランチ。`main`ブランチからマージされると、ステージング環境にデプロイされます。
- **`prod`**: 本番環境用ブランチ。`stg`ブランチからマージされると、本番環境にデプロイされます。

フロー: `main` -> `stg` -> `prod`

### 設定手順

1.  **AWS リソースの準備**

    デプロイ先となる AWS App Runner や ECR などのリソースを準備します。
    以下の Terraform リポジトリを使用すると、必要なリソース一式を構築できます。

    - [https://github.com/campbel2525/sample-apprunner-terraform](https://github.com/campbel2525/sample-apprunner-terraform)

2.  **GitHub Secrets の設定**

    Terraform の apply 後に出力される以下の値を、GitHub リポジトリの`Environments` > `stg` (または `prod`) の Secrets に設定してください。

    | Terraform Output Key             | GitHub Secret Name               |
    | -------------------------------- | -------------------------------- |
    | `region_id`                      | `AWS_REGION`                     |
    | `user_front_apprunner_arn`       | `USER_FRONT_APPRUNNER_ARN`       |
    | `user_front_ecr_name`            | `ECR_REPOSITORY_NAME`            |
    | `github_actions_iam_role`        | `IAM_ROLE`                       |
    | `migration_lambda_function_name` | `MIGRATION_LAMBDA_FUNCTION_NAME` |

3.  **アプリケーションの環境変数の設定**

    `apps/user_front/.env.example`を参考に、アプリケーションで必要な環境変数を AWS Systems Manager (SSM) のパラメータストアに設定してください。

4.  **デプロイの実行**

    `stg`ブランチに変更をプッシュすると、GitHub Actions のワークフローが実行され、ステージング環境に自動でデプロイされます。

#
