#!/bin/bash
# Helper script to run docker-compose with version information from git

# Get version from git tags
export APP_VERSION=$(git describe --tags --always 2>/dev/null || echo "development")
export GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "local")

echo "Building with:"
echo "  APP_VERSION: $APP_VERSION"
echo "  GIT_SHA: $GIT_SHA"
echo ""

# Pass all arguments to docker-compose
docker compose "$@"
