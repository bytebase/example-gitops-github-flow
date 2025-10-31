# About

This repository demonstrates how to use Bytebase and GitHub actions to do database release CI/CD with a code base following [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).

🔗 Tutorial: [GitOps with GitHub Workflow](https://docs.bytebase.com/tutorials/gitops-github-workflow)

For GitHub flow, feature branches are merged into the main branch and the main branch is deployed to the, for example, "test" and "prod" environments in a deploy pipeline.

[sql-review-action.yml](/.github/workflows/sql-review-action.yml) checks the SQL migration files against the databases when pull requests are created.

[release-action.yml](/.github/workflows/release-action.yml) builds the code and then for each environment migrate the databases and deploy the code. Using [environments with protection rules](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment#required-reviewers), it can deploy to the test environment automatically and push to the prod environment after approval.

## Use bytebase/bytebase-action

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
      FILE_PATTERN: "migrations-semver/*.sql" # the glob pattern matching the migration files.
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
      FILE_PATTERN: "migrations-semver/*.sql"
```

In the repository environments setting, create two environments: "test" and "prod". In the "prod" environment setting, configure "Deployment protection rules", check "Required reviewers" and add reviewers in order to rollout the "prod" environment after approval.

Set your service account password in the repository secrets setting with the name `BYTEBASE_SERVICE_ACCOUNT_SECRET`.

> [!IMPORTANT]
> The migration filename SHOULD comply to the naming scheme described in [bytebase-action](https://github.com/bytebase/bytebase/tree/main/action#global-flags) `--file-pattern` flag section.

### How to configure declarative-release-action.yml

Copy [declarative-release-action.yml](/.github/workflows/declarative-release-action.yml) to your repository.

This workflow uses declarative schema management. With declarative mode, you define the desired end state of your database schema, and Bytebase automatically generates and applies the necessary changes.

Modify the environment variables to match your setup.
You need to edit the `create-rollout`, `deploy-to-test` and `deploy-to-prod` jobs.

```yml
    env:
      BYTEBASE_URL: https://demo.bytebase.com
      BYTEBASE_SERVICE_ACCOUNT: api@service.bytebase.com
      BYTEBASE_SERVICE_ACCOUNT_SECRET: ${{ secrets.BYTEBASE_SERVICE_ACCOUNT_SECRET }}
      BYTEBASE_PROJECT: "projects/hr"
      # In the create-rollout job, set the database targets and file pattern
      BYTEBASE_TARGETS: "instances/test-sample-instance/databases/hr_test,instances/prod-sample-instance/databases/hr_prod"
      FILE_PATTERN: "schema/*.sql"
      # In deploy-to-test job:
      BYTEBASE_TARGET_STAGE: environments/test
      # In deploy-to-prod job:
      BYTEBASE_TARGET_STAGE: environments/prod
```

In the repository environments setting, create two environments: "test" and "prod". In the "prod" environment setting, configure "Deployment protection rules", check "Required reviewers" and add reviewers in order to rollout the "prod" environment after approval.

Set your service account password in the repository secrets setting with the name `BYTEBASE_SERVICE_ACCOUNT_SECRET`.

> [!IMPORTANT]
> You must export your initial schema files by clicking **Export Schema** in the database detail page on Bytebase and saving them to the `schema/` directory.

### How to configure chatops-migrate.yml

Copy [chatops-migrate.yml](/.github/workflows/chatops-migrate.yml) to your repository.

This workflow enables ChatOps-style deployments through PR comments. Team members can trigger migrations by commenting `/migrate <environment>` on pull requests.

#### Configuration

1. **Define environments in the workflow**: Edit the `bytebase-action-config.yaml` generation step to define your environments and their database targets.

> [!NOTE]
> The top-level keys (e.g., `test`, `prod`) are used as GitHub Actions job environments, so they must match the environment names configured in your repository settings.


```yml
      - name: Write command config
        run: |
          cat <<EOF > ${{ runner.temp }}/bytebase-action-config.yaml
          test:
            stage: environments/test
            targets:
              - instances/test-sample-instance/databases/hr_test
          prod:
            stage: environments/prod
            targets:
              - instances/prod-sample-instance/databases/hr_prod
          EOF
```

- `stage`: The environment of the databases (e.g., `environments/test`)
- `targets`: List of databases (e.g., `instances/test-sample-instance/databases/hr_test`)

2. **Set environment variables**: Configure these variables in the workflow:

```yml
env:
  BYTEBASE_URL: https://demo.bytebase.com
  BYTEBASE_SERVICE_ACCOUNT: api@service.bytebase.com
  BYTEBASE_SERVICE_ACCOUNT_SECRET: ${{ secrets.BYTEBASE_SERVICE_ACCOUNT_SECRET }}
  BYTEBASE_PROJECT: "projects/hr"
  FILE_PATTERN: "migrations-semver/*.sql"
```

3. **Configure GitHub environments**: Create environments matching your config (e.g., "test", "prod") in repository settings. Add deployment protection rules for production environments.

4. **Add service account secret**: Set `BYTEBASE_SERVICE_ACCOUNT_SECRET` in repository secrets.

#### Usage

- Comment `/migrate <environment>` on a PR to trigger deployment to that environment
- Example: `/migrate prod` deploys to production (requires environment approval if configured)
