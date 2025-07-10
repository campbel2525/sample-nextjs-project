# terraformのdocker内で実行すること

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

fmt: ## 再起的にfmt
	terraform fmt --recursive

stg-init:
	cd project && ./init-stg.sh

stg-apply: ## apply
	make stg-init
	cd project/network && terraform apply -auto-approve -var-file=../terraform.stg.tfvars
	cd project/rds1 && terraform apply -auto-approve -var-file=../terraform.stg.tfvars
	cd project/amplify && terraform apply -auto-approve -var-file=../terraform.stg.tfvars

reset:
	find . -type d -name ".terraform" -exec rm -rf {} +
	find . -type f -name ".terraform.lock.hcl" -exec rm -f {} +
