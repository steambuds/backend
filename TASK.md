# Tasks

## Active Tasks

### Task: STEAM-17 - Google OAuth Authentication
**ID:** STEAM-17
**Title:** Google OAuth Authentication
**Status:** pending
**Created:** 2025-12-28

#### Description
Add Google OAuth authentication as a hybrid system alongside existing password-based authentication. Users can sign up and log in using "Sign in with Google" as an alternative to username/password. OAuth users will be assigned the `:other` role by default.

#### Requirements
- **Hybrid Auth**: Support both Google OAuth and password authentication
- **Account Protection**: Reject Google sign-in if email already exists with password (409 Conflict error)
- **Web Redirect Flow**: Authorization code flow for web frontend
- **Default Role**: Assign `:other` role to new OAuth users automatically
- **Token Response**: Return JWT access token + refresh token (same format as password login)

#### Context
- Current authentication: JWT-based with BCrypt password encryption, 24-hour access tokens, 30-day refresh tokens
- User model uses custom password validation (not `has_secure_password`)
- Registration creates User + Profile in transaction with composite PK (profile.id = user.id)
- OAuth users won't have passwords - need conditional validation
- Business rule: If email exists with password auth, reject OAuth sign-in and force password login

#### Steps

**1. Database Migration**
- [ ] Create migration `db/migrate/[timestamp]_add_oauth_fields_to_users.rb`
- [ ] Add `provider` column (string, nullable) - stores "google" or nil
- [ ] Add `uid` column (string, nullable) - stores Google's unique user ID
- [ ] Add composite unique index on `[provider, uid]`
- [ ] Run migration: `rails db:migrate`

**2. Install Required Gems**
- [ ] Add to Gemfile after line 56: `gem "omniauth-google-oauth2"`, `gem "omniauth-rails_csrf_protection"`
- [ ] Run `bundle install`

**3. Update User Model Validations**
- [ ] Update password validation (lines 11-14) to be conditional: `if: :password_required?`
- [ ] Add OAuth validations: provider must be "google" if present, uid required if provider present, uid unique scoped to provider
- [ ] Add helper method `password_required?` (returns `provider.blank?`)
- [ ] Add class method `self.from_omniauth(auth_hash)` to find user by provider/uid

**4. Configure OmniAuth Strategy**
- [ ] Create `config/initializers/omniauth.rb` with Google OAuth2 strategy configuration
- [ ] Configure scope: 'email,profile', prompt: 'select_account', access_type: 'online'
- [ ] Use credentials from `Rails.application.credentials.dig(:google, :client_id)` or ENV vars
- [ ] Set up Google Cloud Console project and OAuth 2.0 credentials
- [ ] Add credentials to Rails credentials: `rails credentials:edit` (google.client_id, google.client_secret)
- [ ] Configure redirect URIs in Google Console: http://localhost:3000/api/auth/google/callback (dev), https://yourdomain.com/api/auth/google/callback (prod)

**5. Add OAuth Routes**
- [ ] Add to `config/routes.rb` after line 16:
  - `get "auth/:provider/callback", to: "omniauth_callbacks#create"`
  - `get "auth/:provider", to: "omniauth_callbacks#passthrough"`
  - `post "auth/:provider/callback", to: "omniauth_callbacks#create"`
  - `get "auth/failure", to: "omniauth_callbacks#failure"`

**6. Create OmniAuth Callbacks Controller**
- [ ] Create `app/controllers/api/omniauth_callbacks_controller.rb`
- [ ] Implement `passthrough` action (OmniAuth handles redirect)
- [ ] Implement `create` action:
  - Extract email, uid, provider, name from `request.env['omniauth.auth']`
  - Check if email exists with `provider: nil` (password user) → reject with 409 Conflict
  - Check if OAuth user exists via `User.from_omniauth` → login existing user
  - Create new user with provider/uid/email, assign `:other` role
  - Create profile with name from Google (or email prefix as fallback)
  - Use transaction for atomic user + profile creation
  - Generate JWT access token + refresh token
  - Return JSON: `{token, refresh_token, user: {id, email, roles}}`
- [ ] Implement `failure` action for OAuth errors (401 Unauthorized)

**7. Update Test Factories**
- [ ] Add `:google_oauth` trait to `spec/factories/user_factory.rb`:
  - provider: "google"
  - uid: random 21-char alphanumeric
  - password: nil
  - encrypted_password: nil

**8. Configure OmniAuth Test Mode**
- [ ] Add to `spec/rails_helper.rb`:
  - `OmniAuth.config.test_mode = true`
  - Mock Google OAuth response with provider, uid, email, name

**9. Create Request Specs for OAuth**
- [ ] Create `spec/requests/api/omniauth_callbacks_spec.rb`
- [ ] Test case: New user via Google OAuth
  - Creates user with provider/uid
  - Creates profile with name from Google
  - Assigns `:other` role by default
  - Returns JWT + refresh tokens
  - encrypted_password is nil
- [ ] Test case: Existing OAuth user login
  - Finds existing user by provider/uid
  - Returns tokens without creating duplicate
  - User count unchanged
- [ ] Test case: Email exists as password user (rejection)
  - Returns 409 Conflict status
  - Error message: "account with this email already exists"
  - Does not create new user
  - Instructs user to sign in with password
- [ ] Test case: OAuth failure
  - Returns 401 Unauthorized
  - Handles invalid credentials

**10. Add Model Specs for OAuth Validations**
- [ ] Update `spec/models/user_spec.rb` with OAuth tests:
  - OAuth users don't require password
  - Provider must be "google" if present
  - uid required when provider present
  - uid unique scoped to provider
  - `User.from_omniauth` finds user by provider/uid

**11. Final Verification**
- [ ] Run full test suite: `bundle exec rspec`
- [ ] Run linter: `bundle exec rubocop -a`
- [ ] Test OAuth flow manually:
  - New user signup via Google (creates user + profile with `:other` role)
  - Existing OAuth user login (returns tokens, no duplicate)
  - Duplicate email rejection (password user exists, OAuth rejected)
- [ ] Verify JWT tokens contain correct user_id
- [ ] Verify refresh tokens are created and stored
- [ ] Check PaperTrail audit logs for OAuth user creation
- [ ] Update AGENT.md with OAuth authentication documentation

#### Files to Create (4)
- `db/migrate/[timestamp]_add_oauth_fields_to_users.rb` - Migration for provider/uid
- `config/initializers/omniauth.rb` - OmniAuth Google OAuth2 configuration
- `app/controllers/api/omniauth_callbacks_controller.rb` - OAuth callback handler
- `spec/requests/api/omniauth_callbacks_spec.rb` - Request specs for OAuth flow

#### Files to Modify (6)
- `Gemfile` - Add omniauth-google-oauth2, omniauth-rails_csrf_protection
- `app/models/user.rb` - Conditional password validation, OAuth validations, from_omniauth method
- `config/routes.rb` - Add OAuth routes
- `spec/factories/user_factory.rb` - Add :google_oauth trait
- `spec/rails_helper.rb` - Configure OmniAuth test mode
- `spec/models/user_spec.rb` - Add OAuth validation tests

#### Key Implementation Details

**User Model Validation Logic:**
```ruby
validates :password, ..., if: :password_required?
validates :provider, inclusion: { in: %w[google] }, allow_nil: true
validates :uid, presence: true, if: -> { provider.present? }

def password_required?
  provider.blank? # Password required only for non-OAuth users
end

def self.from_omniauth(auth_hash)
  find_by(provider: auth_hash.provider, uid: auth_hash.uid)
end
```

**Business Logic (OmniAuth Callback):**
1. Extract email, uid, provider from OAuth response
2. Check: `User.find_by(email: email, provider: nil)` → if exists, reject (409)
3. Check: `User.from_omniauth(auth_hash)` → if exists, login
4. Create new user: email, provider, uid, roles: [:other]
5. Create profile: id = user.id, name from Google
6. Return JWT + refresh token

**OAuth Routes:**
- `GET /api/auth/google` - Initiates OAuth flow (redirects to Google)
- `GET /api/auth/google/callback` - Handles callback from Google
- `POST /api/auth/google/callback` - Alternative callback method
- `GET /api/auth/failure` - Handles OAuth errors

**Frontend Integration:**
```javascript
// Redirect to backend OAuth endpoint
window.location.href = 'http://localhost:3000/api/auth/google';
```

#### Trade-offs & Decisions
- **Account Protection**: Reject OAuth if email exists as password user (prevents account takeover, simpler than account linking)
- **Profile Data**: OAuth users get minimal profile (name only) - may need completion flow in frontend
- **Default Role**: `:other` role assigned automatically - can be changed by admin later
- **Future Enhancements**: Account linking (let password users add Google), multiple providers (Facebook, Apple)

## Completed Tasks
- **STEAM-9**: User Management Dashboard API (Completed: 2025-12-09)
- **STEAM-10**: Database Schema Migration Updates (Status: 2025-12-08)
- **STEAM-11**: Attendance Dashboard API Endpoints (Completed: 2025-12-10)
- **STEAM-12**: Update Role Enum and Renaming (Completed: 2025-12-22)
- **STEAM-13**: Enhanced User Registration with Profile (Completed: 2025-12-22)
- **STEAM-14**: Daily Visit Tracking Endpoint (Completed: 2025-12-22)
- **STEAM-15**: Refactor User and Profile Schema (Completed: 2025-12-22)
- **STEAM-16**: Revert and Update Registration Logic (Completed: 2025-12-22)

## Task: STEAM-16 - Revert and Update Registration Logic

**ID:** STEAM-16
**Title:** Revert and Update Registration Logic
**Status:** completed
**Created:** 2025-12-22
**Completed:** 2025-12-22

### Description
This task reverts some recent schema changes and updates registration logic:
1.  **Profile Schema:** Add the `steamer_id` column back to `profiles` as a nullable integer.
2.  **Registration Controller:**
    - Do not permit `address` during registration; it should be null/empty.
    - If `role` is not provided during registration, default to an empty array (`[]`).
    - Do not populate `steamer_id` during registration.

### Context
- This task adjusts the registration flow to make `role` and `address` optional and brings back `steamer_id` for potential future use, without populating it automatically.

### Steps
1. [x] **Migration:** Create a migration to add `steamer_id` back to the `profiles` table.
2. [x] **Model Updates:** Update `Profile` model and spec for the re-introduction of `steamer_id`.
3. [x] **Controller Spec Update:** Update `spec/controllers/api/registrations_controller_spec.rb` to test optional role, no address, and no `steamer_id` on registration.
4. [x] **Controller Update:** Update `Api::RegistrationsController` to align with the new logic.
5. [x] **Verification:** Run all tests.
6. [x] **Documentation:** Update relevant documentation.

## Task: STEAM-15 - Refactor User and Profile Schema

**ID:** STEAM-15
**Title:** Refactor User and Profile Schema
**Status:** completed
**Created:** 2025-12-22
**Completed:** 2025-12-22

### Description
This task involves several schema and logic changes:
1.  **User Schema:** Make the `username` column unique but nullable.
2.  **Profile Schema:**
    - Change the `address` column from `text` to `jsonb` to store structured address data (address_1, address_2, district, state, country, pin).
    - Remove the `steamer_id` column.
3.  **Registration Controller:** Update `Api::RegistrationsController` to remove `steamer_id` generation and handle the new structured `address` format.

### Context
- This refactoring simplifies the user and profile models and aligns them with more structured data practices.
- `steamer_id` is being removed, simplifying profile creation.
- `username` is now optional.

### Steps
1. [x] **Migration 1 (Users):** Create a migration to make `username` nullable in the `users` table.
2. [x] **Migration 2 (Profiles)::** Create a migration to change `address` to `jsonb` and remove `steamer_id` from the `profiles` table.
3. [x] **Model Updates:** Update `User` and `Profile` models and their specs to reflect schema changes.
4. [x] **Controller Spec Update:** Update `spec/controllers/api/registrations_controller_spec.rb` for nullable username, new address format, and removal of `steamer_id`.
5. [x] **Controller Update:** Update `Api::RegistrationsController` to align with the new schema and registration flow.
6. [x] **Verification:** Run all tests to ensure no regressions.
7. [x] **Documentation:** Update relevant documentation (`AGENT.md`, `routes_documentation.md`).

## Task: STEAM-14 - Daily Visit Tracking Endpoint

**ID:** STEAM-14
**Title:** Daily Visit Tracking Endpoint
**Status:** completed
**Created:** 2025-12-22
**Completed:** 2025-12-22

### Description
Create an API endpoint to track daily website visits. The endpoint should record the date and increment a visit count. If a record for the current day exists, it should increment the count; otherwise, it should create a new record with a count of 1.

### Context
- **Requirement:** Track daily engagement on the website.
- **Data Structure:** Need a simple table `daily_visits` with `visit_date` (date) and `count` (integer).
- **Behavior:** Upsert logic (create or increment).

### Steps
1. [x] **Migration:** Create `daily_visits` table with `visit_date` (unique index) and `count` (default 0).
2. [x] **Model Spec (TDD):** Create `spec/models/daily_visit_spec.rb` to test validations and increment logic.
3. [x] **Model:** Create `app/models/daily_visit.rb`.
4. [x] **Controller Spec (TDD):** Create `spec/requests/api/daily_visits_spec.rb` to test the tracking endpoint.
5. [x] **Controller & Routes:** Implement `Api::DailyVisitsController#track` and add route `POST /api/track_visit` (or similar).

## Task: STEAM-13 - Enhanced User Registration with Profile

**ID:** STEAM-13
**Title:** Enhanced User Registration with Profile
**Status:** completed
**Created:** 2025-12-22
**Completed:** 2025-12-22

### Description
Update `Api::RegistrationsController` to support creating a full user profile during registration. The API should accept `username`, `email`, `password`, `mobile_number`, `role`, `name`, `gender`, `address`, and `date_of_birth`. It must validate that the role is one of `student`, `teacher`, or `guardian`. Both the `User` and `Profile` records should be created in a single transaction.

### Context
- **Current State:** Registration only creates a `User` with username, email, and password.
- **Requirement:** Need to capture profile data upfront and assign roles.
- **Roles:** Restricted to `student`, `teacher`, `guardian`. `admin`, `school_admin`, `system` are not allowed via public registration.

### Steps
1. [x] **Update Spec (Red):** Modify `spec/controllers/api/registrations_controller_spec.rb` to test for new fields, role validation, and profile creation.
2. [x] **Implement Controller:** Update `Api::RegistrationsController#create` to permit new params, validate roles, and create `User` + `Profile` in a transaction.
3. [x] **Verify (Green):** Run tests to ensure pass.
4. [x] **Documentation:** Update `routes_documentation.md` with the new registration payload.

## Task: STEAM-12 - Update Role Enum and Renaming

**ID:** STEAM-12
**Title:** Update Role Enum and Renaming
**Status:** completed
**Created:** 2025-12-22
**Completed:** 2025-12-22

### Description
Update the `Role` enum to support a specific set of 6 roles: `admin`, `school_admin`, `teacher`, `student`, `system`, `guardian`. This involves renaming existing roles (e.g., `instructor` -> `teacher`, `system_user` -> `system`) and removing unused ones (`facilitator`).

### Context
- **Refactoring:** Widespread changes across codebase, tests, seeds, and documentation.
- **TDD:** Used Red-Green-Refactor approach to ensure no regression.

### Changes
- **Enum:** Updated `app/enums/role.rb`.
- **Code:** Updated `AttendancesController` authorization logic.
- **Tests:** Updated factories and specs (`user_spec`, `group_user_spec`, `authorizable_spec`, `attendances_spec`, etc.).
- **Seeds:** Updated `db/seeds.rb` to use new roles.
- **Docs:** Updated `AGENT.md` and `routes_documentation.md`.

## Task: STEAM-11 - Attendance Dashboard API Endpoints

**ID:** STEAM-11
**Title:** Attendance Dashboard API Endpoints
**Status:** completed
**Created:** 2025-12-10
**Completed:** 2025-12-10

### Description
Create API endpoints to support the teacher's attendance dashboard. This includes listing groups for the current user (teacher), listing students and their attendance history for a specific group, and submitting new attendance records. The API must return data structured to match the `group-5` format in `db.json` for frontend compatibility.

### Context
- **Schema Gaps:** The current `attendances` table (`db/schema.rb`) lacks a `status` column (present, absent, late, excused). This must be added.
- **Missing Models:** `Group`, `GroupUser`, and `Attendance` models need to be created in Rails.
- **Frontend Requirement:** The dashboard expects a nested structure with student details, aggregate stats, and a calendar map of attendance.

### Requirements
- **Teacher Scope:** Teachers should only see groups they are assigned to (via `group_users` table).
- **Attendance Tracking:** Support "present", "absent", "late", "excused".
- **Bulk Entry:** Allow submitting attendance for multiple students in a group for a specific date.
- **Response Format:**
  ```json
  [
    {
      "user_id": 101,
      "steamer_id": 9021001,
      "name": "Student Name",
      "stats": { "present": 20, "absent": 0, "late": 2, "excused": 0 },
      "calendar": {
        "2023-01-09": "present",
        "2023-01-10": "late"
      }
    }
  ]
  ```

### Steps

#### Phase 1: Database & Models (TDD)
1. [x] **Schema Migration:**
   - Generate migration: `bin/rails g migration AddStatusToAttendances status:integer`
   - Run migration: `bin/rails db:migrate`
2. [x] **Group Model:**
   - Create spec `spec/models/group_spec.rb`: Test validations (name present) and associations (`has_many :group_users`, `has_many :users`).
   - Run spec (fail).
   - Create model `app/models/group.rb`: Add validations and associations.
   - Run spec (pass).
3. [x] **GroupUser Model:**
   - Create spec `spec/models/group_user_spec.rb`: Test associations (`belongs_to :group`, `belongs_to :user`) and enum `relation` (student, instructor, facilitator).
   - Run spec (fail).
   - Create model `app/models/group_user.rb`: Add associations and enum.
   - Run spec (pass).
4. [x] **Attendance Model:**
   - Create spec `spec/models/attendance_spec.rb`: Test associations (`belongs_to :group`, `belongs_to :user`), enum `status` (present, absent, late, excused), and validations (date present).
   - Run spec (fail).
   - Create model `app/models/attendance.rb`: Add associations, enum, and validations.
   - Run spec (pass).
5. [x] **Update User & Profile:**
   - Update `spec/models/user_spec.rb`: Test new associations (`has_many :group_users`, `has_many :groups`).
   - Update `app/models/user.rb`: Add associations.

#### Phase 2: API Controllers (TDD)
6. [x] **Routes:**
   - Add nested routes: `resources :groups, only: [:index]` and `resources :groups do resources :attendances, only: [:index, :create] end`.
7. [x] **Groups Controller (List):**
   - Create spec `spec/requests/api/groups_spec.rb`: Test `GET /api/groups` returns only groups where current user is a teacher (instructor/facilitator).
   - Run spec (fail).
   - Implement `Api::GroupsController#index`: Query `current_user.groups`.
   - Run spec (pass).
8. [x] **Attendances Controller (Dashboard Data):**
   - Create spec `spec/requests/api/attendances_spec.rb`: Test `GET /api/groups/:group_id/attendances`.
     - Expect JSON structure: list of students in group.
     - Each student object must include: `user_id`, `steamer_id`, `name`, `stats` (counts), `calendar` (date->status map).
   - Run spec (fail).
   - Implement `Api::AttendancesController#index`:
     - Fetch students for group.
     - Fetch attendance records for these students in this group.
     - Serialize data into required format.
   - Run spec (pass).
9. [x] **Attendances Controller (Bulk Create):**
   - Add to `spec/requests/api/attendances_spec.rb`: Test `POST /api/groups/:group_id/attendances`.
     - Payload: `{ date: "YYYY-MM-DD", attendances: [{ user_id: 1, status: "present" }, ...] }`.
   - Implement `Api::AttendancesController#create`: Iterate and create/update records.
   - Run spec (pass).

#### Phase 3: Final Verification
10. [x] Run full test suite: `bundle exec rspec` to ensure no regressions.

### Contextual Changes

**Files Created:**
- `app/controllers/api/groups_controller.rb`
- `app/controllers/api/attendances_controller.rb`
- `app/models/attendance.rb`
- `spec/factories/group_factory.rb`
- `spec/factories/group_user_factory.rb`
- `spec/factories/attendance_factory.rb`
- `spec/models/attendance_spec.rb`
- `spec/requests/api/groups_spec.rb`
- `spec/requests/api/attendances_spec.rb`

**Files Modified:**
- `app/models/user.rb`
- `config/routes.rb`
- `spec/models/user_spec.rb`
- `AGENT.md` (updated context)

**Key Features Implemented:**
- **Group Management:** Teachers can view their assigned groups.
- **Attendance Dashboard:** Returns aggregated stats and calendar view for students in a group.
- **Bulk Attendance:** Allows teachers to mark attendance for multiple students at once.
