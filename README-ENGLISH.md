# Additional Information

When used in conjunction with the Terraform project [sample-apprunner-terraform](https://www.google.com/search?q=https://github.com/campbel2525/sample-apprunner-terraform/&authuser=8), you can complete the setup for the Next.js application and its infrastructure.

# Sample Next.js Monorepo Project

This project is a sample of a monorepo setup using Next.js and Prisma.
The development environment is built with Docker and can be easily operated using `make` commands.

## Tech Stack

- **Frontend**: Next.js, React, TypeScript
- **Backend**: Next.js (API Routes)
- **ORM**: Prisma
- **Database**: MySQL
- **Container**: Docker, Docker Compose
- **CI/CD**: GitHub Actions, AWS App Runner
- **Lint/Format**: ESLint, Prettier

## Local Development Setup

1. **Set Up Environment Variables**Bash

    Run the following command in the root directory of the repository to copy the sample environment file.

    `make cp-env`

2. **Build and Start the Development Environment**Bash

    Executing the command below will automatically build the Docker containers, set up the database, and install dependencies.

    `make init`

3. **Verify Operation**

    Once the setup is complete, access [http://localhost:3001](https://www.google.com/search?q=http://localhost:3001&authuser=8) in your browser.
    If you can log in with the following credentials, the environment setup was successful.

    - **Email**: `user1@example.com`
    - **Password**: `test1`

## Useful Commands (Makefile)

This project provides `make` commands that wrap the more complex `docker compose` commands.

| Command | Description |
| --- | --- |
| `make help` | Displays all available commands and their descriptions. |
| `make up` | Starts the development environment (Docker containers). |
| `make down` | Stops the development environment. |
| `make reset` | Resets the database and re-seeds it with initial data. |
| `make check` | Runs code formatting and static analysis on all workspaces. |
| `make user-front-shell` | Opens a shell inside the frontend (`user_front`) container. |
| `make migration-shell` | Opens a shell inside the container for scripts (`migration`). |

Google スプレッドシートにエクスポート

For other commands, please refer to the `Makefile` or run `make help`.

### Installing Packages

To add a library to a specific workspace, use the `-w` option.

Bash

`# Example: Install a library in the user_front workspace
npm install <library-name> -w user_front`

## Directory Structure

This repository uses a monorepo structure managed by npm workspaces.

- `apps`: Contains the individual applications.
    - `user_front`: The frontend application built with Next.js.
    - `migration`: Contains development scripts for tasks like DB migrations and seeding.
- `packages`: Contains packages shared across multiple applications.
    - `db`: Contains the Prisma client, schema definitions, and migration files.
    - `factories`: Provides a FactoryBot-like feature for creating test data.
    - `seeders`: Contains seeders for populating the database with initial data.
    - `tsconfig`: Contains shared TypeScript configurations.
- `docker`: Contains Docker-related configuration files.
    - `local`: Contains Docker Compose files for the local development environment.
    - `github_action`: Contains the Dockerfile for deploying to AWS App Runner.

`.
├── apps
│   ├── migration
│   └── user_front
├── packages
│   ├── db
│   │   └── prisma
│   │       └── migrations
│   ├── factories
│   ├── seeders
│   └── tsconfig
├── docker
│   ├── github_action
│   └── local
├── .github/workflows
│   └── cicd.yml
├── Makefile
├── package.json
└── README.md`

## CI/CD

This project uses GitHub Actions to automatically deploy to AWS App Runner, triggered by a push to specific branches.

### Branching Strategy

Development is based on the `main` branch. The deployment flow for each environment is as follows:

- **`main`**: The development branch. Merging into this branch is the standard development practice.
- **`stg`**: The branch for the staging environment. When `main` is merged into this branch, it is deployed to the staging environment.
- **`prod`**: The branch for the production environment. When `stg` is merged into this branch, it is deployed to the production environment.

Flow: `main` -> `stg` -> `prod`

### Setup Instructions

1. **Prepare AWS Resources**

    Set up the necessary AWS resources, such as AWS App Runner and ECR, for deployment.
    You can use the following Terraform repository to provision all required resources.

    - https://github.com/campbel2525/sample-apprunner-terraform
2. **Configure GitHub Secrets**

    After running `terraform apply`, set the following output values as secrets in your GitHub repository under `Environments` > `stg` (or `prod`).

    | Terraform Output Key | GitHub Secret Name |
    | --- | --- |
    | `ap-northeast-1` | `AWS_REGION` |
    | `github_actions_iam_role` | `IAM_ROLE` |
    | `migration_job_definition_name` | `MIGRATION_BATCH_JOB_DEFINITION_NAME` |
    | `migration_job_queue_name` | `MIGRATION_BATCH_JOB_QUEUE_NAME` |
    | `migration_ecr_name` | `MIGRATION_ECR_REPOSITORY_NAME` |
    | `user_front_apprunner_arn` | `USER_FRONT_APPRUNNER_ARN` |
    | `user_front_ecr_name` | `USER_FRONT_ECR_REPOSITORY_NAME` |

    Google スプレッドシートにエクスポート

3. **Set Application Environment Variables**

    Refer to `apps/user_front/.env.example` and `apps/migration/.env.example`, and set the necessary environment variables for your application in the AWS Systems Manager (SSM) Parameter Store.

4. **Execute Deployment**

    Pushing changes to the `stg` branch will trigger the GitHub Actions workflow and automatically deploy to the staging environment.
