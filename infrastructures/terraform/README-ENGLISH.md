# Info

This is the Terraform code for deploying a Next.js application on AWS App Runner.

# Environment Setup

1. Create `infrastructures/terraform/credentials/aws/config` by referring to `infrastructures/terraform/credentials/aws/config.example`.

2. `cd infrastructures/terraform`

3. `make init`

# How to Apply (Staging Environment Example)

1. `cd infrastructures/terraform`

2. `make shell`

3. `cd aws/project`

4. `./init-stg.sh`

5. `make stg-apply`

   - To delete: `make stg-destroy`

# Commands

## Command to get the GitHub fingerprint.

When setting it as an environment variable, convert the uppercase letters to lowercase.

```
openssl s_client -connect token.actions.githubusercontent.com:443 -showcerts \
 </dev/null 2>/dev/null \
 | openssl x509 -noout -fingerprint -sha1 \
 | sed 's/://g' | sed 's/SHA1 Fingerprint=//'

```

# Tips

## 1.

A deployment will always run when you apply the App Runner configuration. It's not possible to prevent this deployment.

Therefore, the infrastructure setup process is as follows:

1. **Create the ECR repository.**
   (e.g.) `terraform apply -auto-approve -target=module.user_front_apprunner.aws_ecr_repository.app -var-file=../terraform.stg.tfvars`
   The specific push process is described in `push_initial_image.sh`.

2. **Push a sample image to AWS.**
   (e.g.) `./push_initial_image.sh aws-stg ap-northeast-1 user-front-repo`

3. **Apply the App Runner configuration.**
   (e.g.) `terraform apply -auto-approve -var-file=../terraform.stg.tfvars`

Please refer to the `stg-apply` target in `infrastructures/terraform/src/aws/project/Makefile`.
