# Version Tracking

The API automatically displays version information at the root endpoint.

## How It Works

### Status Endpoint

**Endpoint:** `GET /`

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-12-20T08:24:05Z",
  "version": "v1.2.3",
  "revision": "abc123f",
  "server": {
    "environment": "production",
    "rails_version": "8.1.1",
    "ruby_version": "3.4.5"
  },
  "database": {
    "connected": true,
    "adapter": "PostgreSQL",
    "database": "backend_production"
  }
}
```

### Version Sources

The version information comes from different sources depending on the environment:

1. **Production (Docker from GitHub Actions)**
   - `version`: From the GitHub release tag (e.g., `v1.2.3`)
   - `revision`: From the git commit SHA (e.g., `abc123f`)
   - Set via build args during Docker build

2. **Development (Local)**
   - `version`: From `git describe --tags --always`
   - `revision`: From `git rev-parse --short HEAD`
   - Requires git to be available

3. **Development (Docker Compose)**
   - `version`: From `APP_VERSION` environment variable or "development"
   - `revision`: From `GIT_SHA` environment variable or "local"
   - Can be set when starting containers

## Implementation

### Code Files

1. **Version Initializer** (`config/initializers/version.rb`)
   - Defines `SteamBuds::Backend.version` and `SteamBuds::Backend.revision`
   - Reads from environment variables or git commands
   - Falls back to "unknown" if neither is available

2. **Status Controller** (`app/controllers/status_controller.rb`)
   - Returns version and revision in JSON response
   - Also includes server and database status

3. **Dockerfile**
   - Accepts `APP_VERSION` and `GIT_SHA` build arguments
   - Sets them as environment variables in the container

4. **GitHub Actions** (`.github/workflows/ci.yml`)
   - Passes release tag and commit SHA as build args
   - Automatically populated when release is published

## Usage

### Check Version in Production

```bash
# Using published image
docker pull ghcr.io/steambuds/backend:latest
docker run -p 3000:3000 ghcr.io/steambuds/backend:latest

# Check version
curl http://localhost:3000 | jq '.version, .revision'
```

### Development with Docker Compose

**Option 1: Using helper script (includes version automatically)**
```bash
./docker-compose.sh up
```

**Option 2: Manual with version**
```bash
APP_VERSION=$(git describe --tags --always) \
GIT_SHA=$(git rev-parse --short HEAD) \
docker compose up
```

**Option 3: Without version (shows defaults)**
```bash
docker compose up
# version will be "development", revision will be "local"
```

### Local Rails Development

```bash
rails server

# Version will be automatically detected from git
curl http://localhost:3000 | jq '.version, .revision'
```

## Publishing Flow

When you publish a release, version tracking happens automatically:

```bash
# 1. Publish release
gh release create v1.2.3 --title "Release 1.2.3" --notes "Bug fixes"

# 2. GitHub Actions builds Docker image with:
#    APP_VERSION=v1.2.3
#    GIT_SHA=abc123f

# 3. Image is published to ghcr.io

# 4. Pull and verify
docker pull ghcr.io/steambuds/backend:1.2.3
curl http://localhost:3000 | jq '.version'
# Output: "v1.2.3"
```

## Environment Variables

| Variable | Description | Default | Set By |
|----------|-------------|---------|--------|
| `APP_VERSION` | Application version from git tag | "development" | GitHub Actions or manual |
| `GIT_SHA` | Git commit SHA (short) | "unknown" | GitHub Actions or manual |

## Examples

### Production Image
```json
{
  "version": "v1.2.3",
  "revision": "abc123f",
  "server": {
    "environment": "production"
  }
}
```

### Development (Local Rails)
```json
{
  "version": "v1.2.3-2-gabc123f",
  "revision": "abc123f",
  "server": {
    "environment": "development"
  }
}
```

### Development (Docker Compose)
```json
{
  "version": "development",
  "revision": "local",
  "server": {
    "environment": "development"
  }
}
```

## Benefits

1. **Debugging:** Know exactly which version is running
2. **Monitoring:** Track deployed versions across environments
3. **Support:** Users can report which version has issues
4. **Audit:** Verify correct version is deployed
5. **CI/CD:** Automated version injection during builds

## Related Files

- `config/initializers/version.rb` - Version detection logic
- `app/controllers/status_controller.rb` - Status endpoint
- `Dockerfile` - Build args and environment variables
- `.github/workflows/ci.yml` - Automatic version injection
- `docker-compose.yml` - Development environment setup
- `docker-compose.sh` - Helper script with auto version detection

## Testing

### Test Status Endpoint
```bash
# Get all info
curl http://localhost:3000 | jq .

# Get just version info
curl http://localhost:3000 | jq '{version, revision}'

# Get server info
curl http://localhost:3000 | jq '.server'

# Get database status
curl http://localhost:3000 | jq '.database'
```

### Test Version Detection
```bash
# In Ruby console
rails console
SteamBuds::Backend.version
# => "v1.2.3" or git describe output

SteamBuds::Backend.revision
# => "abc123f" or git commit SHA
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Version shows "unknown" | No git, no env vars | Set APP_VERSION or use helper script |
| Version shows "development" | Using docker-compose without env vars | Use `./docker-compose.sh up` |
| Version not updating | Old container running | Rebuild: `docker compose build --no-cache` |
| Git version not working | Git not in PATH | Install git or use environment variables |
