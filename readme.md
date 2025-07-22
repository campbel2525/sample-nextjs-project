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
