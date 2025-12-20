# Steam Buds Backend API

Rails 8.0 API-only application for Steam Buds with JWT-based authentication and PostgreSQL database.

## Table of Contents

- [Quick Start with Docker](#quick-start-with-docker)
- [Development Setup](#development-setup)
- [Docker Publishing](#docker-publishing)
- [Manual VPS Setup](#manual-vps-setup)
- [Documentation](#documentation)

## Quick Start with Docker

The fastest way to get started is using Docker:

```bash
# Clone the repository
git clone git@github.com:steambuds/backend.git
cd backend

# Start services
docker compose up
```

The API will be available at `http://localhost:3000`

**Using published images:**

```bash
# Pull latest published image
docker pull ghcr.io/steambuds/backend:latest

# Run with docker-compose
docker compose pull
docker compose up
```

For detailed Docker usage, see [Docker Quick Reference](./DOCKER_QUICK_REFERENCE.md).

## Development Setup

### Prerequisites

- Ruby 3.4.5 (managed via mise)
- PostgreSQL 18
- Git

### Local Setup

1. **Install mise:**
   ```bash
   curl https://mise.run | sh
   echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **Install Ruby:**
   ```bash
   mise install ruby@3.4.5
   ```

3. **Clone and setup:**
   ```bash
   git clone git@github.com:steambuds/backend.git
   cd backend
   bundle install
   ```

4. **Setup database:**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Start server:**
   ```bash
   rails server
   # API available at http://localhost:3000
   ```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code Quality

```bash
# Security scan
bundle exec brakeman

# Linting
bundle exec rubocop

# Auto-fix linting issues
bundle exec rubocop -a
```

## Docker Publishing

This project uses GitHub Actions to automatically build and publish Docker images when you publish a GitHub release.

### Quick Publishing

```bash
# Commit your changes
git add .
git commit -m "Your changes"
git push

# Publish a GitHub release
gh release create v1.0.0 \
  --title "Release v1.0.0" \
  --notes "Your release notes"

# OR use GitHub web interface:
# Go to: https://github.com/steambuds/backend/releases/new
```

GitHub Actions will automatically:
1. Run security scans and tests
2. Build the Docker image
3. Publish to `ghcr.io/steambuds/backend`

**Note:** Images are only published when you **publish a release**, not just when you push tags.

### Published Image Tags

- `ghcr.io/steambuds/backend:latest` - Latest release
- `ghcr.io/steambuds/backend:1.2.3` - Specific version
- `ghcr.io/steambuds/backend:1.2` - Latest minor version
- `ghcr.io/steambuds/backend:1` - Latest major version

**Learn more:**
- **[Docker Publishing Guide](./DOCKER_PUBLISHING.md)** - Complete workflow documentation
- **[Docker Quick Reference](./DOCKER_QUICK_REFERENCE.md)** - Command cheat sheet

## Manual VPS Setup

### Requirements

- Ubuntu/Debian-based VPS
- Git installed
- PostgreSQL installed
- Port 3000 accessible

### Setup Steps

1. **Install mise:**
   ```bash
   curl https://mise.run | sh
   echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **Install Ruby:**
   ```bash
   mise install ruby@3.4.5
   ```

3. **Get the repository:**
   ```bash
   git clone git@github.com:steambuds/backend.git
   cd backend
   ```

4. **Set environment variables:**
   ```bash
   export POSTGRES_USER=postgres
   export POSTGRES_PASSWORD=your_password
   export POSTGRES_HOST=localhost
   export RAILS_ENV=production
   export RAILS_MASTER_KEY=your_master_key
   ```

5. **Install dependencies and setup:**
   ```bash
   bundle install
   rails db:create RAILS_ENV=production
   rails db:migrate RAILS_ENV=production
   rails db:seed RAILS_ENV=production
   ```

6. **Start the server:**
   ```bash
   rails server -e production -b 0.0.0.0
   ```

### Using Docker on VPS (Recommended)

Instead of manual setup, use Docker for easier deployment:

```bash
# Pull published image
docker pull ghcr.io/steambuds/backend:latest

# Run with environment variables
docker run -d -p 3000:3000 \
  -e RAILS_ENV=production \
  -e DATABASE_URL=postgres://user:pass@host:5432/db \
  -e RAILS_MASTER_KEY=your_key \
  --name backend \
  ghcr.io/steambuds/backend:latest
```

Or use docker-compose for full stack:

```bash
# Create docker-compose.yml with production config
docker compose up -d
```

See [DOCKER_PUBLISHING.md](./DOCKER_PUBLISHING.md) for production deployment examples.

## Documentation

### Project Documentation

- **[AGENT.md](./AGENT.md)** - AI agent context and project overview
- **[CLAUDE.md](./CLAUDE.md)** - Claude-specific instructions
- **[routes_documentation.md](./routes_documentation.md)** - API endpoints documentation

### Docker Documentation

- **[DOCKER_PUBLISHING.md](./DOCKER_PUBLISHING.md)** - Complete Docker publishing workflow with diagrams and best practices
- **[DOCKER_QUICK_REFERENCE.md](./DOCKER_QUICK_REFERENCE.md)** - Quick reference for common Docker commands

### Database Documentation

- **[database.canvas](./database.canvas)** - Database schema visualization

## Tech Stack

- **Framework:** Ruby on Rails 8.0 (API-only)
- **Language:** Ruby 3.4.5
- **Database:** PostgreSQL 18
- **Authentication:** JWT with refresh tokens
- **Testing:** RSpec
- **Code Quality:** Rubocop, Brakeman
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **Registry:** GitHub Container Registry (ghcr.io)

## API Endpoints

All endpoints are under `/api` namespace:

- `POST /api/user` - User registration
- `POST /api/login` - User login
- `POST /api/refresh` - Refresh access token
- `DELETE /api/logout` - User logout
- `GET /api/profiles` - List profiles (admin only)
- `GET /api/users` - List users with search and filters (admin only)

For complete API documentation with curl examples, see [routes_documentation.md](./routes_documentation.md).

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests: `bundle exec rspec`
4. Run linter: `bundle exec rubocop`
5. Push and create a Pull Request

## License

[Add your license here]

## Support

For issues or questions, please open an issue on GitHub.

