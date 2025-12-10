# Steam Buds backend api - AI Agent Context
This file provides guidance to any AI when working with code in this repository.
## Project Overview
Rails 8.0 API-only application for Steam Buds backend with JWT-based authentication and PostgreSQL database. Uses mise for Ruby version management.

**Tech Stack:** ruby, rspec, rails, postgres

## AI Agent Instructions
**IMPORTANT:** This file (`AGENT.md`) is the *sole* source of truth for the project context. Any AI agent working on this project must:
1.  **Exclusively** use this file to understand the project's structure, conventions, and goals.
2.  **Update this file** with any new, relevant information or changes discovered during development. Do not rely on external context or previous conversations.
3.  Treat the information herein as the ground truth for all operations.
4.  **Follow the task-based approach** documented below for all development work.

## Task Management Workflow
This project follows a **task-based approach** for all development work:

### Task File
- All tasks are tracked in `task.md`
- Tasks can have multiple steps/sub-tasks during planning
- Each task includes: ID, title, description, status, steps, and contextual changes

### Workflow
1. **Creating Tasks:** When user requests to create a task:
   - Add task to `task.md` with unique ID, title, description
   - Set status to `pending`
   - Reference task in AGENT.md under relevant section if needed

2. **Planning Tasks:** When user requests to plan a task:
   - Read `task.md` to find the task
   - Break down task into detailed steps
   - Update task with step-by-step plan
   - Set status to `planned`

3. **Executing Tasks:** When working on a task:
   - Update status to `in_progress`
   - Complete each step sequentially
   - Document any discoveries or changes

4. **Completing Tasks:** When task is finished:
   - Set status to `completed`
   - Document all contextual changes made
   - **Update AGENT.md with new information in compact manner:**
     - Add/update relevant sections with new features, models, or architectural changes
     - Keep descriptions concise (2-3 sentences per component)
     - Update database schema section if schema changed
     - Update API routes if new endpoints added
     - Remove outdated information that was replaced
   - Add completion date

### Task Statuses
- `pending` - Task created, not yet planned
- `planned` - Steps defined, ready to execute
- `in_progress` - Currently being worked on
- `completed` - Finished with context updated
- `blocked` - Cannot proceed (with reason)

## Database Setup

The application uses PostgreSQL configured via environment variables:
- `POSTGRES_USER` (default: postgres)
- `POSTGRES_PASSWORD` (default: postgres)
- `POSTGRES_HOST` (default: localhost)
- `RAILS_MAX_THREADS` (default: 5)

Database commands:
```bash
rails db:create
rails db:migrate
rails db:seed
rails db:reset  # Drop, create, migrate, seed
```

## Development Commands

Start server:
```bash
rails server
# or
rails s
```

Console:
```bash
rails console
# or
rails c
```

## Testing

This project uses RSpec for testing.

Run all tests:
```bash
bundle exec rspec
```

Run specific test file:
```bash
bundle exec rspec spec/models/user_spec.rb
```

Run specific test:
```bash
bundle exec rspec spec/models/user_spec.rb:10
```

## Audit Trail & History Tracking (PaperTrail)

This project uses **PaperTrail** gem for comprehensive audit trails and version history of all model changes.

### Features
- **Complete History:** Tracks all creates, updates, and deletes
- **Who Changed It:** Records which user made each change (whodunnit)
- **What Changed:** Stores before/after values (changeset)
- **Time Travel:** Ability to revert to any previous version

### Models with Tracking
All major models have `has_paper_trail` enabled:
- User
- Profile
- School
- SchoolUser
- Group
- GroupUser
- Attendance

### Usage Examples

**View version history:**
```ruby
user = User.find(id)
user.versions                    # All versions
user.versions.count              # Number of changes
user.versions.last               # Most recent change
user.versions.last.changeset     # What changed
user.versions.last.whodunnit     # Who made the change (user ID)
```

**Revert to previous version:**
```ruby
user.paper_trail.previous_version  # Get previous state
user.paper_trail.version_at(timestamp)  # State at specific time
```

**Track specific changes:**
```ruby
attendance = Attendance.find(id)
attendance.versions.where(event: 'update')  # Only updates
attendance.versions.last.reify              # Restore previous version
```

### Configuration
- Configured in `ApplicationController` with `set_paper_trail_whodunnit`
- Automatically tracks `current_user.id` for authenticated requests
- Versions stored in `versions` table with polymorphic association

## Project Conventions

### File Naming
Files follow a consistent naming pattern: `[name]_[type].rb`
- **Models:** `user.rb`, `profile.rb` (just the name, no suffix)
- **Controllers:** `users_controller.rb`, `profiles_controller.rb` (plural + _controller)
- **Services:** `json_web_token_service.rb` (name + _service)
- **Factories:** `user_factory.rb`, `profile_factory.rb` (name + _factory)
- **Specs:** Match the file being tested + `_spec.rb` suffix
  - Model specs: `user_spec.rb`, `profile_spec.rb`
  - Controller specs: `users_controller_spec.rb`, `profiles_controller_spec.rb`
  - Service specs: `json_web_token_service_spec.rb`

### Folder Structure
The `spec/` directory mirrors the `app/` directory structure:
- `app/controllers/` ↔️ `spec/controllers/`
- `app/models/` ↔️ `spec/models/`
- `app/services/` ↔️ `spec/services/`
- `app/jobs/` ↔️ `spec/jobs/`
- `spec/factories/` contains all factory files (test data convention)

## Code Quality

Security scanning:
```bash
bundle exec brakeman
```

Linting (Rubocop with Rails Omakase config):
```bash
bundle exec rubocop
```

Auto-fix linting issues:
```bash
bundle exec rubocop -a
```

## Authentication & Authorization Architecture

The application implements a complete JWT-based authentication system with refresh tokens and role-based access control (RBAC):

### Authentication Flow
1. **Registration:** User signs up with username, email, and password (POST /api/user)
2. **Login:** User authenticates and receives both access token (JWT, 24h expiry) and refresh token (30d expiry)
3. **Token Refresh:** Client uses refresh token to obtain new access token without re-authenticating (POST /api/refresh)
4. **Logout:** Refresh token is invalidated/destroyed (DELETE /api/logout)
5. **Protected Endpoints:** Endpoints can require valid JWT in Authorization header

### Key Components

**User Model** (app/models/user.rb)
- Uses bcrypt for password encryption (not Rails' has_secure_password)
- Custom `encrypt_password` callback before save
- Password validation: minimum 8 chars, requires uppercase, lowercase, and digit
- Roles stored as array column on users table (supports multiple roles per user)
- UUID primary keys
- `has_role?(role_name)` method to check if user has a specific role
- `add_role(role)` and `remove_role(role)` methods to manage roles (don't auto-save)

**Role Enum** (app/enums/role.rb)
- Centralized role definitions as Ruby symbols
- Available roles: :admin, :system_user, :instructor, :facilitator, :student
- Used across User.roles, GroupUser.relation, and SchoolUser.relation
- Validates that roles are from approved list

**RefreshToken Model** (app/models/refresh_token.rb)
- Generates secure random hex token on creation
- 30-day expiration from creation
- UUID primary keys
- Belongs to User with dependent destroy

**JsonWebToken Service** (app/services/json_web_token.rb)
- Located in app/services/ (auto-loaded by Rails)
- Uses Rails credentials secret_key_base for JWT signing
- Default access token expiration: 24 hours
- Returns nil on decode errors

**Authenticable Concern** (app/controllers/concerns/authenticable.rb)
- Included in ApplicationController
- Provides `authenticate_request!` method to validate JWT tokens
- Extracts token from Authorization header (format: "Bearer <token>")
- Sets `@current_user` when token is valid
- Returns 401 Unauthorized for missing/invalid/expired tokens
- Provides `current_user` helper method
- Provides `authenticate_if_present` for optional authentication

**RefreshesController** (app/controllers/api/refreshes_controller.rb)
- Handles token refresh requests (POST /api/refresh)
- Validates refresh token from database
- Checks if refresh token is expired
- Generates new access token for valid refresh tokens
- Auto-destroys expired refresh tokens

**Group Management Models**
- **Group:** (app/models/group.rb) Manages class/study groups. Has many users through group_users.
- **GroupUser:** (app/models/group_user.rb) Join table with relation field. Validates user has matching role before assignment.
- **SchoolUser:** (app/models/school_user.rb) Join table for school assignments. Validates user has matching role before assignment.
- **Attendance:** (app/models/attendance.rb) Tracks student attendance with status enum (present/absent/late/excused), includes created_by/updated_by audit trail.

### Database Schema

The database uses UUID primary keys and follows an audit trail pattern with `created_by` and `updated_by` fields on most tables (except hellos). Complete schema documented in `database.canvas`.

**Core Tables:**
- **users:** uuid id (PK), username, email (unique indexed), encrypted_password, mobile_number (indexed), roles (text array), created_by, updated_by
- **profiles:** Composite PK where id = users.id, contains JSONB field (roll_specific_detail), steamer_id (unique), name, bio, avatar_url, father_name, mother_name, gender, alternate_mobile_number, date_of_birth
- **refresh_tokens:** uuid id, user_id FK, token (indexed), expires_at

**School Management:**
- **schools:** uuid id, steamer_id (unique), school_name, district, city_village, pincode, landmark, address, created_by, updated_by
- **school_users:** Composite PK on (school_id, user_id), relation (string - validated against Role enum), created_by, updated_by

**Group & Attendance:**
- **groups:** uuid id, name, about, grades, same_school boolean, created_by, updated_by
- **group_users:** Composite PK on (group_id, user_id), relation (string - validated against Role enum), created_by, updated_by
- **attendances:** uuid id, group_id, user_id, attendance_at (all indexed), status (enum: 0=present, 1=absent, 2=late, 3=excused), created_by, updated_by

**Contact Form:**
- **hellos:** uuid id, name, email, mobile_number, description, category (intentionally no audit fields)

### Protecting Endpoints with Authentication

To require JWT authentication on a controller action:

```ruby
class MyController < ApplicationController
  before_action :authenticate_request!, only: [:protected_action]

  def protected_action
    # @current_user is available here
    render json: { user: current_user.username }
  end

  def public_action
    # No authentication required
  end
end
```

**Examples in codebase:**
- `GET /api/hello` - See authorization section below (requires admin role)
- `DELETE /api/hello/:id` - See authorization section below (requires admin role)
- `POST /api/hello` is public (no authentication)
- Registration, login, logout, and refresh are public endpoints

**Note:** For endpoints that require authorization (role checking), use `authorize_role!` instead of `authenticate_request!` - it handles both authentication and authorization in one step.

### Protecting Endpoints with Authorization (Role-Based Access Control)

The application includes role-based authorization through the **Authorizable concern** (app/controllers/concerns/authorizable.rb).

**Available Roles:**
- `:admin` - Administrator role with full access to all protected endpoints
- `:system_user` - System/automated process role
- `:instructor` - Teacher role for leading groups and marking attendance
- `:facilitator` - Community facilitator role for supporting groups
- `:student` - Student role for group membership and attendance tracking

**Authorizable Concern:**
- Included in ApplicationController
- Provides `authorize_role!(*allowed_roles)` method
- **Automatically handles authentication** - internally calls `authenticate_request!` if needed
- Checks if current_user has any of the specified roles
- Returns 403 Forbidden if user lacks required role
- Returns 401 Unauthorized if user is not authenticated
- **No need to call `authenticate_request!` separately** when using `authorize_role!`

**Usage Examples:**

Single role requirement:
```ruby
class AdminController < ApplicationController
  before_action -> { authorize_role!(:admin) }

  def index
    # Only users with admin role can access this
    # Authentication is handled automatically by authorize_role!
    render json: { message: "Admin access granted" }
  end
end
```

Multiple roles allowed (user needs ANY of these roles):
```ruby
class ReportsController < ApplicationController
  before_action -> { authorize_role!(:admin, :manager) }

  def index
    # Users with either admin OR manager role can access
    # Authentication is handled automatically by authorize_role!
    render json: Report.all
  end
end
```

Per-action authorization (mixing protected and public endpoints):
```ruby
class HelloController < ApplicationController
  # Only need authorize_role! - it handles authentication internally
  before_action -> { authorize_role!(:admin) }, only: [:index, :destroy]

  def index
    # Requires authentication AND admin role
    # Both handled automatically by authorize_role!
    render json: Hello.all
  end

  def destroy
    # Requires authentication AND admin role
    # Both handled automatically by authorize_role!
    Hello.find(params[:id]).destroy
    render json: { message: "Deleted" }
  end

  def create
    # No authentication or authorization required - public endpoint
    hello = Hello.new(hello_params)
    if hello.save
      render json: hello, status: :created
    else
      render json: { errors: hello.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
```

**Authorization Flow:**
1. Request comes in with JWT token in Authorization header
2. `authorize_role!` is called (from before_action)
3. **Internally**, `authorize_role!` calls `authenticate_request!` to validate token and set `@current_user`
4. Then checks if `current_user.has_role?(role)` for any allowed role
5. If authorized: request proceeds to action
6. If not authorized: returns 403 Forbidden
7. If not authenticated: returns 401 Unauthorized

**Note:** When using `authorize_role!`, you don't need to call `authenticate_request!` separately - authentication is handled automatically.

**Real-world examples in codebase:**
- `GET /api/hello` requires admin role (app/controllers/api/hello_controller.rb:3)
- `DELETE /api/hello/:id` requires admin role (app/controllers/api/hello_controller.rb:3)
- `POST /api/hello` is a public endpoint (no authentication or authorization required)

## User Profiles

**Profile Model** (app/models/profile.rb)
- One-to-one with User using composite PK where `profiles.id = users.id`
- User type determined by user_roles (teacher/student roles), not stored in profile
- Common fields: name, bio, avatar_url, gender, address, date_of_birth, father_name, mother_name, alternate_mobile_number
- JSONB fields for flexible data:
  - `roll_specific_detail`: Stores both teacher and student data
    - teacher: {years_of_experience, qualification, subjects: []}
    - student: {grade, section, roll_number, enrollment_date}
  - `experience`: [{type, description, duration, organization}]
- Unique `steamer_id` for external system integration

**Authorization Pattern** (app/controllers/api/profiles_controller.rb)
- All endpoints require JWT authentication
- Index (GET /api/profiles): admin only
- Show/Update/Delete: own profile OR admin (custom `authorize_profile_access!` method)
- Create: any authenticated user (one profile per user enforced)

## API Routes

All API endpoints are namespaced under `/api` and return JSON:

### Authentication Endpoints (Public)
```ruby
POST   /api/user          # User registration
POST   /api/login         # User login (returns access + refresh tokens)
POST   /api/refresh       # Refresh access token
DELETE /api/logout        # User logout (invalidates refresh token)
```

### Profile Endpoints (Protected - JWT Required)
```ruby
GET    /api/profiles      # List all (admin only)
GET    /api/profiles/:id  # Get (own or admin)
POST   /api/profiles      # Create (one per user)
PUT    /api/profiles/:id  # Update (own or admin)
DELETE /api/profiles/:id  # Delete (own or admin)
```

### User Management Endpoints (Protected - Admin Role Required)
```ruby
GET    /api/users                    # List users (pagination, search, filters)
GET    /api/users/:id                # Get user details with profile & roles
POST   /api/users/:id/roles          # Add role to user
DELETE /api/users/:id/roles/:role    # Remove role from user
PUT    /api/users/:id/roles          # Update all user roles
```

**Features:**
- **Pagination:** Default 20/page, max 100 (params: `page`, `per_page`)
- **Search:** Fuzzy match on email/phone (param: `search`)
- **Filters:** By role or profile_type (params: `role`, `profile_type`)
- **Controller:** `Api::UsersController` (app/controllers/api/users_controller.rb)

### Protected Endpoints with Authorization (Require JWT + Role)
```ruby
GET    /api/hello         # List all hellos (requires: Bearer token + admin role)
DELETE /api/hello/:id     # Delete hello (requires: Bearer token + admin role)
```

### Public Endpoints (No Auth Required)
```ruby
POST   /api/hello         # Create hello
```

See `routes_documentation.md` for detailed curl examples with request/response formats.

## Deployment

The project includes Kamal configuration for deployment (config/deploy.yml).

## Environment Setup

Ruby version management uses mise. From the README, the setup process is:
```bash
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
mise install ruby@[version]
```
