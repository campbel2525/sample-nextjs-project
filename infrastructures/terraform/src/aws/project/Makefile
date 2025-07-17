# terraformのdocker内で実行すること

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

fmt: ## 再起的にfmt
	terraform fmt --recursive

stg-init:
	./init-stg.sh

stg-apply: ## apply
	make stg-init
	cd network && terraform apply -auto-approve -var-file=../terraform.stg.tfvars
	cd rds1 && terraform apply -auto-approve -var-file=../terraform.stg.tfvars
	cd amplify_user_app && terraform apply -auto-approve -var-file=../terraform.stg.tfvars

stg-destroy: ## destroy
	make stg-init
	cd amplify_user_app && terraform destroy -auto-approve -var-file=../terraform.stg.tfvars
	cd rds1 && terraform destroy -auto-approve -var-file=../terraform.stg.tfvars
	cd network && terraform destroy -auto-approve -var-file=../terraform.stg.tfvars

reset:
	find . -type d -name ".terraform" -exec rm -rf {} +
	find . -type f -name ".terraform.lock.hcl" -exec rm -f {} +
