# Docker Quick Reference

Quick commands for Docker image publishing and usage.

**Full Documentation:** For detailed explanations and troubleshooting, see [DOCKER_PUBLISHING.md](./DOCKER_PUBLISHING.md)
**Back to:** [README.md](./README.md)

## Publishing a New Version

```bash
# 1. Commit and push your changes
git add .
git commit -m "Your changes"
git push

# 2. Publish a GitHub release (Option A: GitHub CLI)
gh release create v1.2.3 \
  --title "Release v1.2.3" \
  --notes "Description of changes"

# OR Option B: Create tag first, then publish release on GitHub
git tag v1.2.3
git push origin v1.2.3
# Then go to GitHub → Releases → Create release from tag

# OR Option C: Use GitHub web interface
# Go to: https://github.com/steambuds/backend/releases/new

# That's it! GitHub Actions will handle the rest.
```

## Pulling Images

```bash
# Latest version
docker pull ghcr.io/steambuds/backend:latest

# Specific version
docker pull ghcr.io/steambuds/backend:1.2.3

# Latest minor (e.g., latest 1.2.x)
docker pull ghcr.io/steambuds/backend:1.2

# Latest major (e.g., latest 1.x.x)
docker pull ghcr.io/steambuds/backend:1
```

## Running the Image

```bash
# Simple run
docker run -p 3000:3000 ghcr.io/steambuds/backend:latest

# With environment variables
docker run -p 3000:3000 \
  -e RAILS_ENV=production \
  -e DATABASE_URL=postgres://user:pass@db:5432/dbname \
  ghcr.io/steambuds/backend:latest

# With docker-compose
docker compose pull
docker compose up
```

## Version Format (Semantic Versioning)

| Type | Command | Example | When to Use |
|------|---------|---------|-------------|
| **Patch** | `gh release create v1.0.1` | Bug fix | Small fixes, no new features |
| **Minor** | `gh release create v1.1.0` | New feature | New features, backward compatible |
| **Major** | `gh release create v2.0.0` | Breaking change | API changes, breaking updates |
| **Pre-release** | `gh release create v1.0.0-beta.1 --prerelease` | Beta version | Testing before release |

## Common Tasks

### Check published versions
```bash
# Via GitHub web
https://github.com/orgs/steambuds/packages/container/backend

# Via API
curl https://api.github.com/orgs/steambuds/packages/container/backend/versions
```

### Login to GitHub Container Registry
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

### Delete a release and tag
```bash
# Delete release
gh release delete v1.0.0 --yes

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
```

### Check workflow status
```bash
# Web
https://github.com/steambuds/backend/actions

# Or watch in terminal
gh run list --workflow=ci.yml
gh run watch
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow doesn't trigger | Ensure you **published a release**, not just pushed a tag |
| Tests fail | Run `bundle exec rspec` locally first |
| Can't pull image | Login with `docker login ghcr.io` or make package public |
| Build fails | Test locally with `docker build -t test .` |
| Draft release | Draft releases don't trigger builds - click "Publish release" |

## Docker Compose Production Example

```yaml
services:
  api:
    image: ghcr.io/steambuds/backend:1.2.3  # Pin version!
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      RAILS_ENV: production
      DATABASE_URL: ${DATABASE_URL}
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY}
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:18
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}

volumes:
  postgres_data:
```

## Links

- **Full Documentation**: [DOCKER_PUBLISHING.md](./DOCKER_PUBLISHING.md)
- **GitHub Packages**: https://github.com/orgs/steambuds/packages
- **GitHub Actions**: https://github.com/steambuds/backend/actions
- **Semantic Versioning**: https://semver.org/
