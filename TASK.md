# Tasks

## Active Tasks

## Completed Tasks
- **STEAM-9**: User Management Dashboard API (Completed: 2025-12-09)
- **STEAM-10**: Database Schema Migration Updates (Status: 2025-12-08)
- **STEAM-11**: Attendance Dashboard API Endpoints (Completed: 2025-12-10)
- **STEAM-12**: Update Role Enum and Renaming (Completed: 2025-12-22)


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
