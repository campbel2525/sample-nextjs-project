# info

next.js を AWS App Runner で公開する Terraform のコードになります

# 環境設定

1. `infrastructures/terraform/credentials/aws/config.example`を参考にして`infrastructures/terraform/credentials/aws/config`を作成

2. `cd infrastructures/terraform`

3. `make init`

# apply 方法(stg 環境の例)

1. `cd infrastructures/terraform`
2. `make shell`
3. `cd aws/project`
4. `./init-stg.sh`
5. `make stg-apply`
   削除する場合: `make stg-destro`

# コマンド

## github の finger print を取得するコマンド。

環境変数に設置する際には大文字を小文字に変換すること

```
openssl s_client -connect token.actions.githubusercontent.com:443 -showcerts \
 </dev/null 2>/dev/null \
 | openssl x509 -noout -fingerprint -sha1 \
 | sed 's/://g' | sed 's/SHA1 Fingerprint=//'
```

# Tips

## 1

App Runner を apply する際にデプロイが必ず走ります。デプロイを走らないようにするのは不可能です。

そのためインフラの構築は

1. Ecr を作成
   (例) `terraform apply -auto-approve -target=module.user_front_apprunner.aws_ecr_repository.app -var-file=../terraform.stg.tfvars`
   push の具体的な処理は`push_initial_image.sh`に書いてあります。s
2. AWS にあるサンプル image を push
   (例) `./push_initial_image.sh aws-stg ap-northeast-1 user-front-repo`
3. App Runner を apply
   (例) `terraform apply -auto-approve -var-file=../terraform.stg.tfvars`

という流れになっています。

`infrastructures/terraform/src/aws/project/Makefile`の`stg-apply`を参照
