# Docker Image Publishing Workflow

This document describes the automated Docker image publishing process for the Steam Buds backend API.

**Quick Reference:** For a condensed command cheat sheet, see [DOCKER_QUICK_REFERENCE.md](./DOCKER_QUICK_REFERENCE.md)
**Back to:** [README.md](./README.md)

## Overview

Docker images are automatically built and published to GitHub Container Registry (ghcr.io) when you publish a GitHub release. The CI/CD pipeline ensures all tests pass before publishing.

## Publishing Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         1. Develop & Commit                              │
│                                                                           │
│  - Make changes to codebase                                              │
│  - Commit changes to main branch                                         │
│  - Push to GitHub                                                        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    2. Publish GitHub Release                             │
│                                                                           │
│  - Create tag: git tag v1.2.3 && git push origin v1.2.3                 │
│  - Publish release on GitHub (web UI or gh CLI)                         │
│  - OR: Use "gh release create v1.2.3" to do both                        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    3. GitHub Actions CI Pipeline                         │
│                                                                           │
│  ┌─────────────────────┐                                                │
│  │ Security Scan       │  → Brakeman static analysis                     │
│  └─────────────────────┘                                                │
│                                                                           │
│  ┌─────────────────────┐                                                │
│  │ Lint Code           │  → Rubocop style checks                        │
│  └─────────────────────┘                                                │
│                                                                           │
│  ┌─────────────────────┐                                                │
│  │ Run Tests           │  → RSpec test suite                            │
│  └─────────────────────┘                                                │
│           │                                                               │
│           ▼ (all pass)                                                   │
│  ┌─────────────────────┐                                                │
│  │ Build Docker Image  │  → Multi-stage Docker build                    │
│  └─────────────────────┘                                                │
│           │                                                               │
│           ▼                                                               │
│  ┌─────────────────────┐                                                │
│  │ Push to ghcr.io     │  → Publish with multiple tags                  │
│  └─────────────────────┘                                                │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    4. Images Available on ghcr.io                        │
│                                                                           │
│  ghcr.io/steambuds/backend:1.2.3    (exact version)                     │
│  ghcr.io/steambuds/backend:1.2      (minor version)                     │
│  ghcr.io/steambuds/backend:1        (major version)                     │
│  ghcr.io/steambuds/backend:latest   (latest release)                    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Guide

### 1. Develop and Commit Changes

```bash
# Make your code changes
git add .
git commit -m "Add new feature: user authentication"
git push origin main
```

### 2. Create a Tag and Publish a GitHub Release

Follow [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH):
- **MAJOR** version for incompatible API changes (v2.0.0)
- **MINOR** version for new features (v1.1.0)
- **PATCH** version for bug fixes (v1.0.1)

**Option A: Using GitHub Web Interface (Recommended)**

1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Click "Choose a tag" and create new tag (e.g., `v1.2.3`)
4. Fill in release title and description
5. Click "Publish release"

**Option B: Using GitHub CLI**

```bash
# Create and push tag
git tag v1.2.3
git push origin v1.2.3

# Create and publish release
gh release create v1.2.3 \
  --title "Release v1.2.3" \
  --notes "Add user authentication and profile management"
```

**Option C: Tag first, then create release**

```bash
# Create annotated tag
git tag -a v1.2.3 -m "Release version 1.2.3: Add user authentication"
git push origin v1.2.3

# Then go to GitHub and create a release from this tag
```

**Important:** Docker images are only published when you **publish a GitHub release**, not just when you push a tag. This gives you control over when images are made available.

### 3. Monitor the CI/CD Pipeline

1. Go to your GitHub repository
2. Click on "Actions" tab
3. Find the workflow run for your tag
4. Monitor the progress:
   - ✅ Security Scan (Brakeman)
   - ✅ Lint (Rubocop)
   - ✅ Tests (RSpec)
   - ✅ Docker Build & Push

**If any step fails**, the Docker image will NOT be published. Fix the issues and create a new tag.

### 4. Verify Published Images

Once the workflow completes successfully:

**View on GitHub:**
1. Go to `https://github.com/orgs/steambuds/packages`
2. Click on `backend` package
3. See all published versions

**View available tags:**
```bash
# List all tags for the repository
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/orgs/steambuds/packages/container/backend/versions
```

## Pulling and Using Images

### Pull Latest Release

```bash
# Pull the latest published version
docker pull ghcr.io/steambuds/backend:latest

# Run the container
docker run -p 3000:3000 \
  -e POSTGRES_HOST=db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=backend_production \
  -e DATABASE_URL=postgres://postgres:postgres@db:5432/backend_production \
  ghcr.io/steambuds/backend:latest
```

### Pull Specific Version

```bash
# Pull exact version
docker pull ghcr.io/steambuds/backend:1.2.3

# Pull latest minor version (e.g., latest 1.2.x)
docker pull ghcr.io/steambuds/backend:1.2

# Pull latest major version (e.g., latest 1.x.x)
docker pull ghcr.io/steambuds/backend:1
```

### Use in Docker Compose

Update your `docker-compose.yml` to use the published image:

```yaml
services:
  api:
    image: ghcr.io/steambuds/backend:latest  # or specific version like :1.2.3
    ports:
      - "3000:3000"
    environment:
      RAILS_ENV: production
      POSTGRES_HOST: db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: backend_production
      DATABASE_URL: postgres://postgres:postgres@db:5432/backend_production
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:18
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: backend_production
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  db_data:
```

Then run:

```bash
docker compose pull  # Pull latest images
docker compose up    # Start services
```

### Use in Production

For production deployments, always pin to specific versions:

```yaml
services:
  api:
    image: ghcr.io/steambuds/backend:1.2.3  # Pin to exact version
    # ... rest of configuration
```

**Benefits of pinning versions:**
- Predictable deployments
- Easy rollbacks
- No unexpected changes from `latest` tag

## Authentication for Private Packages

If your package is private, authenticate before pulling:

### Using Personal Access Token

```bash
# Create a token at https://github.com/settings/tokens
# with 'read:packages' permission

echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
docker pull ghcr.io/steambuds/backend:latest
```

### In CI/CD Environments

```yaml
- name: Login to GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

## Making Packages Public

To allow anyone to pull without authentication:

1. Go to `https://github.com/orgs/steambuds/packages`
2. Click on `backend` package
3. Click "Package settings"
4. Scroll to "Danger Zone"
5. Click "Change visibility" → "Public"
6. Confirm the change

## Release Examples

```bash
# Initial release
gh release create v1.0.0 --title "Initial Release" --notes "First stable release"

# Bug fix
gh release create v1.0.1 --title "Bug Fix Release" --notes "Fixed authentication issue"

# New feature (backward compatible)
gh release create v1.1.0 --title "Feature Release" --notes "Added profile management"

# Breaking changes
gh release create v2.0.0 --title "Major Release" --notes "Breaking: New API structure"

# Pre-release versions
gh release create v1.2.0-beta.1 --title "Beta Release" --notes "Testing new features" --prerelease
```

**Or using the GitHub web interface:**
1. Go to `https://github.com/steambuds/backend/releases/new`
2. Choose or create tag (e.g., `v1.0.0`)
3. Fill in title and description
4. Click "Publish release"

## Troubleshooting

### Workflow doesn't trigger
- Ensure you **published a GitHub release**, not just pushed a tag
- Tag must start with 'v' (e.g., `v1.0.0` not `1.0.0`)
- Check GitHub Actions is enabled for your repository
- Verify the workflow file exists at `.github/workflows/ci.yml`
- Check the release status: Draft releases don't trigger the workflow

### Tests fail
- Run tests locally first: `bundle exec rspec`
- Check test logs in GitHub Actions
- Fix issues and create a new tag

### Docker build fails
- Ensure Dockerfile is valid: `docker build -t test .`
- Check for missing dependencies
- Verify all files are committed

### Cannot pull image
- Check if package is public or you're authenticated
- Verify the image tag exists: `https://github.com/orgs/steambuds/packages/container/backend`
- Ensure you're using the correct image name

### Delete a release and tag
```bash
# Delete the release using GitHub CLI
gh release delete v1.0.0 --yes

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
```

**Or via GitHub web interface:**
1. Go to repository releases
2. Click on the release
3. Click "Delete" button
4. Then delete the tag if needed

## Best Practices

1. **Always test before tagging**: Run `bundle exec rspec` locally
2. **Use semantic versioning**: Follow MAJOR.MINOR.PATCH format
3. **Write meaningful tag messages**: `git tag -a v1.0.0 -m "Initial release"`
4. **Pin versions in production**: Don't use `latest` in production
5. **Document breaking changes**: Update CHANGELOG.md for major versions
6. **Test the published image**: Pull and run it before deploying

## Related Files

- **Workflow**: `.github/workflows/ci.yml` - CI/CD pipeline configuration
- **Dockerfile**: `Dockerfile` - Docker image build instructions
- **Docker Compose**: `docker-compose.yml` - Local development setup
- **Entrypoint**: `bin/docker-entrypoint` - Container initialization script

## Resources

- [Semantic Versioning](https://semver.org/)
- [GitHub Container Registry Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Metadata Action](https://github.com/docker/metadata-action)
