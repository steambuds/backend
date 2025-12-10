# Tasks

## Active Tasks
- **STEAM-10:** Database Schema Migration Updates (Status: pending)

## Completed Tasks
- **STEAM-9:** User Management Dashboard API (Completed: 2025-12-09)


## Task: STEAM-9 - User Management Dashboard API

**ID:** STEAM-9
**Title:** Design and Implement User Management Dashboard API
**Status:** done
**Created:** 2025-12-09

### Description
Create a comprehensive dashboard API that allows admin users to manage users in the system. The dashboard should provide:

1. **User Listing:** Display all users with their profiles and roles
2. **Fuzzy Search:** Allow searching users by email and phone number with fuzzy matching capabilities
3. **Role Management:** Enable admin users to assign/update/remove roles for any user

### Requirements

#### Functional Requirements:
- Admin-only access to all dashboard endpoints
- List all users with pagination support
- Search users by email and phone number (fuzzy/partial matching)
- Filter users by role type (admin, manager, server_machine)
- Filter users by profile type (teacher, student)
- View detailed user information including profile and assigned roles
- Add roles to users
- Remove roles from users
- Update user roles

#### Technical Requirements:
- RESTful API design
- Proper authorization (admin role required)
- Input validation and error handling
- Search should be case-insensitive
- Pagination for large datasets
- Consistent JSON response format

### Proposed Endpoints

```
# User Dashboard Endpoints (All require admin role)
GET    /api/admin/users                    # List all users with pagination & search
GET    /api/admin/users/:id                # Get detailed user info with profile and roles
POST   /api/admin/users/:id/roles          # Add role to user
DELETE /api/admin/users/:id/roles/:role    # Remove role from user
PUT    /api/admin/users/:id/roles          # Update user roles (replace all)
```

### Query Parameters for GET /api/admin/users:
- `page` (integer): Page number for pagination (default: 1)
- `per_page` (integer): Records per page (default: 20, max: 100)
- `search` (string): Fuzzy search on email and phone number
- `role` (string): Filter by user role (admin, manager, server_machine)
- `profile_type` (string): Filter by profile type (teacher, student)

### Expected Response Formats:

**List Users Response:**
```json
{
  "users": [
    {
      "id": "uuid",
      "username": "string",
      "email": "string",
      "mobile_number": "string",
      "created_at": "timestamp",
      "roles": ["admin", "manager"],
      "profile": {
        "user_type": "teacher",
        "bio": "string",
        // other profile fields based on user_type
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 95
  }
}
```

**Get User Detail Response:**
```json
{
  "id": "uuid",
  "username": "string",
  "email": "string",
  "mobile_number": "string",
  "created_at": "timestamp",
  "updated_at": "timestamp",
  "roles": ["admin"],
  "profile": {
    "id": "uuid",
    "user_type": "teacher",
    "bio": "string",
    "subjects_taught": "string",
    "years_experience": 10,
    // all profile fields
  }
}
```

**Add/Update Roles Response:**
```json
{
  "message": "Role(s) updated successfully",
  "user": {
    "id": "uuid",
    "username": "string",
    "roles": ["admin", "manager"]
  }
}
```

### Implementation Steps
1. ✅ Created `Api::Admin::UsersController` with admin authorization
2. ✅ Implemented user listing with pagination (default: 20, max: 100 per page)
3. ✅ Implemented fuzzy search on email and phone (case-insensitive ILIKE)
4. ✅ Implemented filtering by role and profile_type
5. ✅ Implemented role management endpoints (add, remove, update)
6. ✅ Added routes under `/api/admin` namespace
7. ✅ Created comprehensive RSpec tests (40 test cases, all passing)
8. ✅ Updated routes_documentation.md with examples

### Contextual Changes

**Files Created:**
- `app/controllers/api/admin/users_controller.rb` - Admin users management controller
- `spec/requests/api/admin/users_spec.rb` - Comprehensive test suite

**Files Modified:**
- `config/routes.rb` - Added admin namespace with user management routes
- `routes_documentation.md` - Added detailed API documentation for all admin endpoints
- `AGENT.md` - Referenced task in Active Tasks section

**Key Features Implemented:**
- **Pagination:** Configurable page size (default 20, max 100)
- **Search:** Fuzzy matching on email and mobile_number using PostgreSQL ILIKE
- **Filters:** Role-based and profile_type filtering with SQL joins
- **Authorization:** All endpoints require admin role via `authorize_role!(:admin)`
- **Role Management:** Add, remove, or bulk update user roles
- **Response Format:** Consistent JSON with user details, profile summary, and pagination metadata
- **Error Handling:** Proper 401/403/404/422 status codes with descriptive error messages

---

## Task: STEAM-10 - Database Schema Migration Updates

**ID:** STEAM-10
**Title:** Update Database Migrations to Match Schema Design
**Status:** completed
**Created:** 2025-12-10
**Completed:** 2025-12-10

### Description
Update existing database migrations and create new migrations to match the finalized database schema in `database.canvas`. The migrations have not been published to production yet, so they can be safely modified. All migrations must be rollback-friendly and readable.

### Requirements

#### Migration Principles:
- **Rollback-friendly:** Every migration must have proper `up` and `down` methods or reversible changes
- **Readable:** Clear comments, descriptive names, logical organization
- **Idempotent:** Safe to run multiple times (use `if_exists`, `if_not_exists` where appropriate)
- **Atomic:** Each migration should handle one logical change
- **No data loss:** Preserve existing data when modifying columns

### Changes Required

#### 1. Update Existing Migrations

**A. users migration (20251004072045_create_users.rb)**
- ✅ Already has: id as uuid, email unique index, mobile_number unique index
- ❌ Need to add: created_by (uuid FK), updated_by (uuid FK)
- ❌ Need to change: mobile_number index from unique to non-unique (schema shows just index)

**B. profiles migration (20251108063811_create_profiles.rb)**
- ❌ **Major refactor needed:**
  - Change from separate `id` + `user_id` to composite PK where `id = users.id`
  - Remove: user_type, phone, subjects_taught, years_experience, qualification, grade_level, enrollment_date, parent_contact
  - Add: name, steamer_id (unique, indexed), father_name, mother_name, gender, teacher_detail (jsonb), experience (jsonb), student_details (jsonb), alternate_mobile_number
  - Add: created_by (uuid FK), updated_by (uuid FK)

**C. user_roles migration (20251101033928_create_user_roles.rb)**
- ❌ **Refactor to composite PK:**
  - Remove: id column
  - Change to composite primary_key on [user_id, role]
  - Keep: unique index on [user_id, role]
  - Add: created_by (uuid FK), updated_by (uuid FK)

**D. refresh_tokens migration (20251004072420_create_refresh_tokens.rb)**
- ✅ Already has: id, user_id FK, token, expires_at
- ❌ Need to add: created_by (uuid FK), updated_by (uuid FK)

**E. hellos migration (20250821201333_create_hellos.rb)**
- ✅ Intentionally has no audit fields (contact form table)
- ✅ No changes needed

#### 2. Create New Migrations

**A. schools table**
```ruby
create_table :schools, id: :uuid do |t|
  t.integer :steamer_id, null: false
  t.string :school_name, null: false
  t.string :district, null: false
  t.string :city_village
  t.integer :pincode
  t.string :landmark
  t.string :address
  t.uuid :created_by
  t.uuid :updated_by
  t.timestamps null: false
end
add_index :schools, :steamer_id, unique: true
add_foreign_key :schools, :users, column: :created_by
add_foreign_key :schools, :users, column: :updated_by
```

**B. school_users join table**
```ruby
create_table :school_users, id: false do |t|
  t.uuid :school_id, null: false
  t.uuid :user_id, null: false
  t.string :relation, null: false # instructor, facilitator, student, principal
  t.uuid :created_by
  t.uuid :updated_by
  t.timestamps null: false
end
add_index :school_users, [:school_id, :user_id], unique: true
execute "ALTER TABLE school_users ADD PRIMARY KEY (school_id, user_id);"
add_foreign_key :school_users, :schools
add_foreign_key :school_users, :users
add_foreign_key :school_users, :users, column: :created_by
add_foreign_key :school_users, :users, column: :updated_by
```

**C. groups table**
```ruby
create_table :groups, id: :uuid do |t|
  t.string :name, null: false
  t.string :about
  t.string :grades
  t.boolean :same_school, default: false
  t.uuid :created_by
  t.uuid :updated_by
  t.timestamps null: false
end
add_foreign_key :groups, :users, column: :created_by
add_foreign_key :groups, :users, column: :updated_by
```

**D. group_users join table**
```ruby
create_table :group_users, id: false do |t|
  t.uuid :group_id, null: false
  t.uuid :user_id, null: false
  t.string :relation, null: false # student, instructor, facilitator
  t.uuid :created_by
  t.uuid :updated_by
  t.timestamps null: false
end
add_index :group_users, [:group_id, :user_id], unique: true
add_index :group_users, :group_id
add_index :group_users, :user_id
execute "ALTER TABLE group_users ADD PRIMARY KEY (group_id, user_id);"
add_foreign_key :group_users, :groups
add_foreign_key :group_users, :users
add_foreign_key :group_users, :users, column: :created_by
add_foreign_key :group_users, :users, column: :updated_by
```

**E. attendances table**
```ruby
create_table :attendances, id: :uuid do |t|
  t.uuid :group_id, null: false
  t.uuid :user_id, null: false
  t.datetime :attendance_at, null: false
  t.uuid :created_by
  t.uuid :updated_by
  t.timestamps null: false
end
add_index :attendances, :group_id
add_index :attendances, :user_id
add_index :attendances, :attendance_at
add_foreign_key :attendances, :groups
add_foreign_key :attendances, :users
add_foreign_key :attendances, :users, column: :created_by
add_foreign_key :attendances, :users, column: :updated_by
```

### Implementation Steps

1. **Review existing migrations** and understand current schema state
2. **Update users migration** - Add audit fields, adjust mobile_number index
3. **Update profiles migration** - Complete refactor to composite PK with JSON fields
4. **Update user_roles migration** - Convert to composite PK
5. **Update refresh_tokens migration** - Add audit fields
6. **Create schools migration** - New table with audit trail
7. **Create school_users migration** - Join table with composite PK
8. **Create groups migration** - New table with audit trail
9. **Create group_users migration** - Join table with composite PK
10. **Create attendances migration** - New table with indexes
11. **Test migrations** - Run `rails db:migrate` and verify
12. **Test rollbacks** - Run `rails db:rollback` for each migration
13. **Update schema.rb** - Verify final schema matches database.canvas
14. **Update AGENT.md** - Document any implementation decisions

### Acceptance Criteria

- [ ] All existing migrations updated to match schema design
- [ ] All new tables created with proper migrations
- [ ] All migrations are rollback-friendly (can run `db:rollback` successfully)
- [ ] All composite primary keys properly implemented
- [ ] All indexes created as specified in schema
- [ ] All foreign keys have proper constraints
- [ ] Audit trail (created_by, updated_by) on all tables except hellos
- [ ] JSON columns use jsonb type for better performance
- [ ] Migrations include clear comments explaining complex changes
- [ ] Schema matches database.canvas exactly
- [ ] All migrations tested: `rails db:migrate && rails db:rollback && rails db:migrate`

### Notes

- migrations have NOT been published to production, so we can safely modify existing files
- Use `change_column` with `reversible` block for non-reversible changes
- Use jsonb (not json) for better PostgreSQL performance and indexing
- Consider adding check constraints for enum-like string columns (relation, role)
- Self-referential foreign keys (created_by, updated_by) should allow NULL initially

### Contextual Changes

**Completed on 2025-12-10**

#### Files Modified:
1. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251004072045_create_users.rb`
   - Added `created_by` and `updated_by` audit fields
   - Changed `mobile_number` index from unique to non-unique
   - Added self-referential foreign keys for audit trail

2. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251108063811_create_profiles.rb`
   - Complete refactor to composite PK where `profiles.id = users.id`
   - Removed old fields: `user_type`, `phone`, `subjects_taught`, `years_experience`, `qualification`, `grade_level`, `enrollment_date`, `parent_contact`
   - Added new fields: `name`, `steamer_id`, `father_name`, `mother_name`, `gender`, `alternate_mobile_number`
   - Added JSONB fields: `teacher_detail`, `experience`, `student_details`
   - Added audit trail fields and foreign keys
   - Added unique index on `steamer_id`

3. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251101033928_create_user_roles.rb`
   - Converted to composite PK on `[user_id, role]`
   - Changed from `change` to `up/down` methods for proper rollback
   - Added audit trail fields and foreign keys

4. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251004072420_create_refresh_tokens.rb`
   - Added `created_by` and `updated_by` audit fields
   - Added self-referential foreign keys

#### Files Created:
5. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251210041355_create_schools.rb`
   - New schools table with uuid PK
   - Unique index on `steamer_id`
   - Audit trail with foreign keys

6. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251210041359_create_school_users.rb`
   - Join table with composite PK `[school_id, user_id]`
   - `relation` field for role (instructor, facilitator, student, principal)
   - Used `up/down` methods for proper rollback with execute statement
   - Audit trail with foreign keys

7. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251210041407_create_groups.rb`
   - New groups table with uuid PK
   - Fields: `name`, `about`, `grades`, `same_school`
   - Audit trail with foreign keys

8. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251210041410_create_group_users.rb`
   - Join table with composite PK `[group_id, user_id]`
   - `relation` field for role (student, instructor, facilitator)
   - Multiple indexes for query performance
   - Used `up/down` methods for proper rollback
   - Audit trail with foreign keys

9. `/Users/ghadmin/steam_buds/app/backend/db/migrate/20251210041414_create_attendances.rb`
   - New attendances table with uuid PK
   - Indexes on `group_id`, `user_id`, and `attendance_at`
   - Audit trail with foreign keys

#### Implementation Decisions:

1. **Composite Primary Keys:** Used `execute "ALTER TABLE ... ADD PRIMARY KEY (...)"` with `up/down` methods instead of `change` to ensure proper rollback capability.

2. **JSONB over JSON:** All JSON columns use `jsonb` type for better PostgreSQL performance and indexing capabilities.

3. **Profiles Composite PK:** Implemented using `add_foreign_key :profiles, :users, column: :id, primary_key: :id` to create the constraint where `profiles.id = users.id`.

4. **Audit Trail Pattern:** All tables except `hellos` have nullable `created_by` and `updated_by` fields with self-referential foreign keys to `users` table.

5. **Index Strategy:**
   - Unique indexes on `steamer_id` for both profiles and schools
   - Composite unique indexes on join tables
   - Performance indexes on frequently queried columns (attendance_at, group_id, user_id)

#### Testing Results:

- `rails db:drop db:create db:migrate` - SUCCESS (all migrations applied)
- `rails db:rollback STEP=10` - SUCCESS (all migrations rolled back)
- `rails db:migrate` - SUCCESS (re-applied successfully)
- Schema verified against database.canvas - MATCH

#### Acceptance Criteria Status:

- [x] All existing migrations updated to match schema design
- [x] All new tables created with proper migrations
- [x] All migrations are rollback-friendly (can run `db:rollback` successfully)
- [x] All composite primary keys properly implemented
- [x] All indexes created as specified in schema
- [x] All foreign keys have proper constraints
- [x] Audit trail (created_by, updated_by) on all tables except hellos
- [x] JSON columns use jsonb type for better performance
- [x] Migrations include clear comments explaining complex changes
- [x] Schema matches database.canvas exactly
- [x] All migrations tested: `rails db:migrate && rails db:rollback && rails db:migrate`

---
