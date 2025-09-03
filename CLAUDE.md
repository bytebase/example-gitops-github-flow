# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitOps demonstration repository for database CI/CD using Bytebase and GitHub Actions with GitHub Flow. The repository shows how to integrate database schema changes with application deployment pipelines.

## Repository Structure

- `migrations-semver/`: Contains SQL migration files following semantic versioning naming convention (e.g., `1.0.0_init.sql`, `1.1.1_comment.sql`)
- `schema/`: Contains base database schema definitions
- `.github/workflows/`: GitHub Actions workflows for CI/CD pipeline

## Migration File Naming

Migration files MUST follow semantic versioning pattern: `{major}.{minor}.{patch}_{description}.sql`
- Examples: `1.0.0_init.sql`, `1.1.1_comment.sql`, `1.13.0_phone.sql`
- Files are processed by Bytebase in semantic version order

## GitHub Actions Workflows

### SQL Review Workflow (`sql-review-action.yml`)
- Triggers on pull requests to `main` branch when `migrations-semver/*.sql` files change
- Uses `bytebase/bytebase-action:latest` Docker image
- Runs SQL validation against production database
- Requires `BYTEBASE_SERVICE_ACCOUNT_SECRET` repository secret

### Release Workflow (`release-action.yml`)
- Triggers on push to `main` branch when `migrations-semver/*.sql` files change
- Three-stage process:
  1. `build`: Mock application build step
  2. `create-rollout`: Creates Bytebase rollout plan for both test and prod databases
  3. `deploy-to-test`: Deploys to test environment automatically
  4. `deploy-to-prod`: Deploys to production (requires manual approval via GitHub environment protection)

## Environment Configuration

Both workflows use these environment variables:
- `BYTEBASE_URL`: Bytebase instance URL
- `BYTEBASE_SERVICE_ACCOUNT`: Service account email
- `BYTEBASE_SERVICE_ACCOUNT_SECRET`: Service account password (stored in GitHub secrets)
- `BYTEBASE_PROJECT`: Target Bytebase project
- `BYTEBASE_TARGETS`: Comma-separated list of database targets
- `FILE_PATTERN`: Glob pattern for migration files (`migrations-semver/*.sql`)

## Database Schema

The schema includes:
- Employee management system with tables: `employee`, `department`, `dept_manager`, `dept_emp`, `title`, `salary`
- Audit logging system with trigger-based change tracking
- Views for current department assignments

## Development Workflow

1. Create feature branch
2. Add SQL migration files to `migrations-semver/` with proper semantic versioning
3. Create pull request - triggers SQL review workflow
4. Merge to main - triggers release workflow
5. Test environment deployment happens automatically
6. Production deployment requires manual approval through GitHub environment protection

## Key Integration Points

- All database changes go through Bytebase for review and deployment
- GitHub environment protection rules control production deployments
- Migration files are validated against actual database schemas during PR review