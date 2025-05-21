# About

This repository demonstrates how to use Bytebase and GitHub actions to do database release CI/CD with a code base following [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).

For GitHub flow, feature branches are merged into the main branch and the main branch is deployed to the, for example, "test" and "prod" environments in a deploy pipeline.

[sql-review-action.yml](/.github/workflows/sql-review-action.yml) checks the SQL migration files against the databases when pull requests are created.

[release-action.yml](/.github/workflows/release-action.yml) builds the code and then for each environment migrate the databases and deploy the code. Using [environments with protection rules](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment#required-reviewers), it can deploy to the test environment automatically and push to the prod environment after approval.

## Use bytebase/bytebase-action (recommended)

The README of bytebase/bytebase-action can be found at [README](https://github.com/bytebase/bytebase/blob/main/action/README.md).

### How to configure sql-review-action.yml

Copy [sql-review-action.yml](/.github/workflows/sql-review-action.yml) to your repository.

Modify the environment variables to match your setup.

```yml
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # set GITHUB_TOKEN because the 'Check release' step needs it to comment the pull request with check results.
      BYTEBASE_URL: https://demo.bytebase.com
      BYTEBASE_SERVICE_ACCOUNT: ci@service.bytebase.com
      BYTEBASE_SERVICE_ACCOUNT_SECRET: ${{secrets.BYTEBASE_SERVICE_ACCOUNT_SECRET}}
      BYTEBASE_PROJECT: "projects/project-sample"
      BYTEBASE_TARGETS: "instances/test-sample-instance/databases/hr_test" # the database targets to check against.
      FILE_PATTERN: "migrations/*.sql" # the glob pattern matching the migration files.
```

Set your service account password in the repository secrets setting with the name `BYTEBASE_SERVICE_ACCOUNT_SECRET`.

> [!IMPORTANT]
> The migration filename SHOULD comply to the naming scheme described in [bytebase-action](https://github.com/bytebase/bytebase/tree/main/action#global-flags) `--file-pattern` flag section.

### How to configure release-action.yml

Copy [release-action.yml](/.github/workflows/release-action.yml) to your repository.

Modify the environment variables to match your setup.
You need to edit both deploy-to-test and deploy-to-prod jobs.

```yml
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      BYTEBASE_URL: https://demo.bytebase.com
      BYTEBASE_SERVICE_ACCOUNT: ci@service.bytebase.com
      BYTEBASE_SERVICE_ACCOUNT_SECRET: ${{secrets.BYTEBASE_SERVICE_ACCOUNT_SECRET}}
      BYTEBASE_PROJECT: "projects/project-sample"
      # The Bytebase rollout pipeline will deploy to 'test' and 'prod' environments.
      # 'deploy_to_test' job rollouts the 'test' stage and 'deploy_to_prod' job rollouts the 'prod' stage.
      BYTEBASE_TARGETS: "instances/test-sample-instance/databases/hr_test,instances/prod-sample-instance/databases/hr_prod"
      BYTEBASE_TARGET_STAGE: environments/test
      FILE_PATTERN: "migrations/*.sql"
```

In the repository environments setting, create two environments: "test" and "prod". In the "prod" environment setting, configure "Deployment protection rules", check "Required reviewers" and add reviewers in order to rollout the "prod" environment after approval.

Set your service account password in the repository secrets setting with the name `BYTEBASE_SERVICE_ACCOUNT_SECRET`.

> [!IMPORTANT]
> The migration filename SHOULD comply to the naming scheme described in [bytebase-action](https://github.com/bytebase/bytebase/tree/main/action#global-flags) `--file-pattern` flag section.

## Use javascript actions 

### How to configure sql-review.yml

Copy [sql-review.yml](/.github/workflows/sql-review.yml) to your repository.

Modify the environment variables to match your setup.

```yml
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # set GITHUB_TOKEN because the 'Check release' step needs it to comment the pull request with check results.
      BYTEBASE_URL: https://demo.bytebase.com
      BYTEBASE_SERVICE_ACCOUNT: ci@service.bytebase.com
      BYTEBASE_PROJECT: "projects/project-sample"
      BYTEBASE_TARGETS: "instances/test-sample-instance/databases/hr_test" # the database targets to check against.
      FILE_PATTERN: "migrations/*.sql" # the glob pattern matching the migration files.
```

Set your service account password in the repository secrets setting with the name `BYTEBASE_SERVICE_ACCOUNT_SECRET`.

> [!IMPORTANT]
> The migration filename SHOULD comply to the naming scheme described in [bytebase-action](https://github.com/bytebase/bytebase/tree/main/action#global-flags) `--file-pattern` flag section.

### How to configure release.yml

Copy [release.yml](/.github/workflows/release.yml) to your repository.

Modify the environment variables to match your setup.

```yml
    env:
      BYTEBASE_URL: https://demo.bytebase.com
      BYTEBASE_SERVICE_ACCOUNT: ci@service.bytebase.com
      BYTEBASE_PROJECT: "projects/project-sample"
      # The Bytebase rollout pipeline will deploy to 'test' and 'prod' environments.
      # 'deploy_to_test' job rollouts the 'test' stage and 'deploy_to_prod' job rollouts the 'prod' stage.
      BYTEBASE_TARGETS: "instances/test-sample-instance/databases/hr_test,instances/prod-sample-instance/databases/hr_prod"
      FILE_PATTERN: "migrations/*.sql" # the glob pattern matching the migration files.
```

In the repository environments setting, create two environments: "test" and "prod". In the "prod" environment setting, configure "Deployment protection rules", check "Required reviewers" and add reviewers in order to rollout the "prod" environment after approval.

Set your service account password in the repository secrets setting with the name `BYTEBASE_SERVICE_ACCOUNT_SECRET`.

> [!IMPORTANT]
> The migration filename SHOULD comply to the naming scheme described in [bytebase-action](https://github.com/bytebase/bytebase/tree/main/action#global-flags) `--file-pattern` flag section.