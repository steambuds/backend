# API Documentation

## Authentication Routes

### User Registration

Creates a new user account with profile and role.

**Endpoint:** `POST /api/user`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "username": "testuser",
  "email": "test@example2.com",
  "password": "Password123",
  "mobile_number": "+1234567890",
  "role": "student",
  "name": "Test User",
  "gender": "male",
  "address": "123 Test Lane",
  "date_of_birth": "2000-01-01"
}' http://localhost:8000/api/user
```

**Allowed Roles:** `student`, `teacher`, `guardian`

**Response:**
```json
{
  "id": "uuid",
  "username": "testuser",
  "email": "test@example2.com",
  "roles": ["student"],
  "profile": {
    "id": "uuid",
    "steamer_id": 9000001,
    "name": "Test User",
    "gender": "male",
    "address": "123 Test Lane",
    "date_of_birth": "2000-01-01",
    ...
  }
}
```

---

### User Login

Logs in a user and returns a JWT access token and a refresh token.

**Endpoint:** `POST /api/login`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" -d 
  "{
    \"email\": \"ghanshyam@steambuds.com\",
    \"password\": \"Password123\"
  }" http://localhost:8000/api/login
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "a1b2c3d4e5f6..."
}
```

---

### User Logout

Logs out a user by invalidating the refresh token.

**Endpoint:** `DELETE /api/logout`

**Request:**
```bash
curl -X DELETE -H "Content-Type: application/json" -d 
  "{
    \"refresh_token\": \"your_refresh_token\"
  }" http://localhost:8000/api/logout
```

**Response:** `204 No Content`

---

### Refresh Access Token

Generates a new access token using a valid refresh token.

**Endpoint:** `POST /api/refresh`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" -d 
  "{
    \"refresh_token\": \"your_refresh_token\"
  }" http://localhost:8000/api/refresh
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

---

## Hello Routes

### Get All Hellos

Retrieves a list of all "hello" records. **Requires JWT authentication and admin role.**

**Endpoint:** `GET /api/hello`

**Request:**
```bash
curl -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/hello
```

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "description": "This is a test.",
    "mobile_number": "+1234567890",
    "category": "General",
    "created_at": "2025-11-01T10:00:00.000Z",
    "updated_at": "2025-11-01T10:00:00.000Z"
  }
]
```

---

### Create a Hello

Creates a new "hello" record. **Does not require authentication.**

**Endpoint:** `POST /api/hello`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" -d 
  "{
    \"name\": \"John Doe\",
    \"email\": \"john.doe@example.com\",
    \"description\": \"This is a test message.\",
    \"mobile_number\": \"+1234567890\",
    \"category\": \"General\"
  }" http://localhost:8000/api/hello
```

**Note:** Either `email` or `mobile_number` must be provided (or both).

**Response:**
```json
{
  "id": "uuid",
  "name": "John Doe",
  "email": "john.doe@example.com",
  "description": "This is a test message.",
  "mobile_number": "+1234567890",
  "category": "General",
  "created_at": "2025-11-01T10:00:00.000Z",
  "updated_at": "2025-11-01T10:00:00.000Z"
}
```

---

### Delete a Hello

Deletes a specific "hello" record by ID. **Requires JWT authentication and admin role.**

**Endpoint:** `DELETE /api/hello/:id`

**Request:**
```bash
curl -X DELETE -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/hello/uuid-here
```

**Response (Success):**
```json
{
  "message": "Hello deleted successfully"
}
```

**Response (Not Found):**
```json
{
  "error": "Hello not found"
}
```

**Response (Unauthorized - missing or invalid token):**
```json
{
  "error": "Unauthorized",
  "message": "Authentication token is missing or invalid"
}
```

**Response (Forbidden - user lacks admin role):**
```json
{
  "error": "Forbidden",
  "message": "You do not have permission to access this resource"
}
```

---

## Daily Visit Tracking

### Track a Website Visit

Records a visit for the current day, incrementing the counter. This is a public endpoint.

**Endpoint:** `POST /api/track_visit`

**Request:**
```bash
curl -X POST http://localhost:8000/api/track_visit
```

**Response (Success):**
```json
{
  "status": "success",
  "visit_date": "2025-12-22",
  "count": 1
}
```
*`count` will be higher for subsequent requests on the same day.*

---

## Profile Routes

### Get All Profiles

Retrieves a list of all user profiles. **Requires JWT authentication and admin role.**

**Endpoint:** `GET /api/profiles`

**Request:**
```bash
curl -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/profiles
```

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "Arjun Kumar",
    "steamer_id": 9000001,
    "father_name": "Rajesh Kumar",
    "mother_name": "Priya Kumar",
    "gender": "male",
    "bio": "A passionate student.",
    "avatar_url": "http://example.com/avatar.jpg",
    "alternate_mobile_number": "+1234567890",
    "address": "123 Main St",
    "date_of_birth": "2000-01-01",
    "roll_specific_detail": {
      "student": {
        "grade": "10",
        "section": "A",
        "roll_number": "10A001",
        "enrollment_date": "2023-09-01"
      }
    },
    "experience": [],
    "created_at": "2025-11-01T10:00:00.000Z",
    "updated_at": "2025-11-01T10:00:00.000Z"
  }
]
```

---

### Get a Single Profile

Retrieves a specific user profile by ID. **Requires JWT authentication. Users can only access their own profile unless they have the admin role.**

**Endpoint:** `GET /api/profiles/:id`

**Request:**
```bash
curl -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/profiles/uuid-here
```

**Response:**
```json
{
  "id": "uuid",
  "name": "Arjun Kumar",
  "steamer_id": 9000001,
  "father_name": "Rajesh Kumar",
  "mother_name": "Priya Kumar",
  "gender": "male",
  "bio": "A passionate student.",
  "avatar_url": "http://example.com/avatar.jpg",
  "alternate_mobile_number": "+1234567890",
  "address": "123 Main St",
  "date_of_birth": "2000-01-01",
  "roll_specific_detail": {
    "student": {
      "grade": "10",
      "section": "A",
      "roll_number": "10A001",
      "enrollment_date": "2023-09-01"
    }
  },
  "experience": [],
  "created_at": "2025-11-01T10:00:00.000Z",
  "updated_at": "2025-11-01T10:00:00.000Z"
}
```

---

### Create a Profile

Creates a new user profile. **Requires JWT authentication. Each user can only have one profile.**

**Endpoint:** `POST /api/profiles`

**Request (Student Example):**
```bash
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer your_access_token" -d 
  "{
    \"name\": \"Arjun Kumar\",
    \"steamer_id\": 9000001,
    \"father_name\": \"Rajesh Kumar\",
    \"mother_name\": \"Priya Kumar\",
    \"gender\": \"male\",
    \"bio\": \"A passionate student.\",
    \"avatar_url\": \"http://example.com/avatar.jpg\",
    \"alternate_mobile_number\": \"+1234567890\",
    \"address\": \"123 Main St\",
    \"date_of_birth\": \"2000-01-01\",
    \"roll_specific_detail\": {
      \"student\": {
        \"grade\": \"10\",
        \"section\": \"A\",
        \"roll_number\": \"10A001\",
        \"enrollment_date\": \"2023-09-01\"
      }
    },
    "experience": []
  }" http://localhost:8000/api/profiles
```

**Request (Teacher Example):**
```bash
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer your_access_token" -d 
  "{
    \"name\": \"Priya Sharma\",
    \"steamer_id\": 9000002,
    \"father_name\": \"Mohan Sharma\",
    \"mother_name\": \"Lakshmi Sharma\",
    \"gender\": \"female\",
    \"bio\": \"Experienced mathematics teacher.\",
    \"avatar_url\": \"http://example.com/avatar.jpg\",
    \"alternate_mobile_number\": \"+1234567891\",
    \"address\": \"456 Teacher Lane\",
    \"date_of_birth\": \"1985-05-15\",
    \"roll_specific_detail\": {
      \"teacher\": {
        \"years_of_experience\": 10,
        \"qualification\": \"M.Sc. Mathematics\",
        \"subjects\": [\"Mathematics\", \"Physics\"]
      }
    },
    "experience": [
      {
        "type": "teaching",
        "description": "Mathematics teacher at ABC School",
        "duration": "2015-2020",
        "organization": "ABC School"
      }
    ]
  }" http://localhost:8000/api/profiles
```

**Response:**
```json
{
  "id": "uuid",
  "name": "Arjun Kumar",
  "steamer_id": 9000001,
  "father_name": "Rajesh Kumar",
  "mother_name": "Priya Kumar",
  "gender": "male",
  "bio": "A passionate student.",
  "avatar_url": "http://example.com/avatar.jpg",
  "alternate_mobile_number": "+1234567890",
  "address": "123 Main St",
  "date_of_birth": "2000-01-01",
  "roll_specific_detail": {
    "student": {
      "grade": "10",
      "section": "A",
      "roll_number": "10A001",
      "enrollment_date": "2023-09-01"
    }
  },
  "experience": [],
  "created_at": "2025-11-01T10:00:00.000Z",
  "updated_at": "2025-11-01T10:00:00.000Z"
}
```

---

### Update a Profile

Updates an existing user profile. **Requires JWT authentication. Users can only update their own profile unless they have the admin role.**

**Endpoint:** `PUT/PATCH /api/profiles/:id`

**Request:**
```bash
curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer your_access_token" -d 
  "{
    \"bio\": \"An updated bio for the student.\",
    \"address\": \"456 New Address\"
  }" http://localhost:8000/api/profiles/uuid-here
```

**Response:**
```json
{
  "id": "uuid",
  "name": "Arjun Kumar",
  "steamer_id": 9000001,
  "father_name": "Rajesh Kumar",
  "mother_name": "Priya Kumar",
  "gender": "male",
  "bio": "An updated bio for the student.",
  "avatar_url": "http://example.com/avatar.jpg",
  "alternate_mobile_number": "+1234567890",
  "address": "456 New Address",
  "date_of_birth": "2000-01-01",
  "roll_specific_detail": {
    "student": {
      "grade": "10",
      "section": "A",
      "roll_number": "10A001",
      "enrollment_date": "2023-09-01"
    }
  },
  "experience": [],
  "created_at": "2025-11-01T10:00:00.000Z",
  "updated_at": "2025-11-01T10:30:00.000Z"
}
```

---

### Delete a Profile

Deletes a specific user profile. **Requires JWT authentication. Users can only delete their own profile unless they have the admin role.**

**Endpoint:** `DELETE /api/profiles/:id`

**Request:**
```bash
curl -X DELETE -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/profiles/uuid-here
```

**Response (Success):**
```json
{
  "message": "Profile deleted successfully"
}
```

**Response (Not Found):**
```json
{
  "error": "Profile not found"
}
```

**Response (Unauthorized - missing or invalid token):**
```json
{
  "error": "Unauthorized",
  "message": "Authentication token is missing or invalid"
}
```

**Response (Forbidden - user lacks access or admin role):**
```json
{
  "error": "Forbidden",
  "message": "Forbidden: You can only access your own profile"
}
```

---

## User Management Routes

### List All Users

Retrieves a paginated list of all users with their profiles and roles. Supports search and filtering. **Requires JWT authentication and admin role.**

**Endpoint:** `GET /api/users`

**Query Parameters:**
- `search` (optional): Fuzzy search on email and phone number
- `role` (optional): Filter by user role (admin, school_admin, teacher, student, system, guardian)
- `profile_type` (optional): Filter by profile type (teacher, student)
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Records per page (default: 20, max: 100)

**Request:**
```bash
# Get all users with pagination
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/users?page=1&per_page=20

# Search users by email or phone
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/users?search=john@example.com

# Filter by role
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/users?role=admin

# Filter by profile type
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/users?profile_type=teacher

# Combined filters and search
curl -X GET -H "Authorization: Bearer your_access_token" \
  "http://localhost:8000/api/users?search=john&role=manager&page=1&per_page=10"
```

**Response:**
```json
{
  "users": [
    {
      "id": "uuid",
      "username": "johndoe",
      "email": "john@example.com",
      "mobile_number": "+1234567890",
      "created_at": "2024-01-15T10:30:00Z",
      "roles": ["admin", "teacher"],
      "profile": {
        "name": "John Doe",
        "bio": "Experienced mathematics teacher"
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

---

### Get User Details

Retrieves detailed information about a specific user including full profile and roles. **Requires JWT authentication and admin role.**

**Endpoint:** `GET /api/users/:id`

**Request:**
```bash
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/users/user_uuid
```

**Response:**
```json
{
  "id": "uuid",
  "username": "johndoe",
  "email": "john@example.com",
  "mobile_number": "+1234567890",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-20T14:45:00Z",
  "roles": ["admin"],
  "profile": {
    "id": "profile_uuid",
    "name": "John Doe",
    "steamer_id": 9000001,
    "father_name": "Robert Doe",
    "mother_name": "Jane Doe",
    "gender": "male",
    "bio": "Experienced mathematics teacher",
    "avatar_url": "https://example.com/avatar.jpg",
    "alternate_mobile_number": "+1234567890",
    "address": "123 Main St, City, Country",
    "date_of_birth": "1985-05-15",
    "roll_specific_detail": {
      "teacher": {
        "years_of_experience": 10,
        "qualification": "PhD in Mathematics",
        "subjects": ["Mathematics", "Physics"]
      }
    },
    "experience": []
  }
}
```

**Error Response (User Not Found):**
```json
{
  "error": "User not found"
}
```

---

### Add Role to User

Adds a specific role to a user. **Requires JWT authentication and admin role.**

**Endpoint:** `POST /api/users/:id/roles`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_access_token" \
  -d '{"role": "manager"}' \
  http://localhost:8000/api/users/user_uuid/roles
```

**Response:**
```json
{
  "message": "Role added successfully",
  "user": {
    "id": "uuid",
    "username": "johndoe",
    "roles": ["admin", "manager"]
  }
}
```

**Error Response (Invalid Role):**
```json
{
  "error": "Invalid role. Valid roles are: admin, school_admin, teacher, student, system, guardian"
}
```

**Error Response (Duplicate Role):**
```json
{
  "error": "User already has this role"
}
```

---

### Remove Role from User

Removes a specific role from a user. **Requires JWT authentication and admin role.**

**Endpoint:** `DELETE /api/users/:id/roles/:role`

**Request:**
```bash
curl -X DELETE -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/users/user_uuid/roles/manager
```

**Response:**
```json
{
  "message": "Role removed successfully",
  "user": {
    "id": "uuid",
    "username": "johndoe",
    "roles": ["admin"]
  }
}
```

**Error Response (Role Not Found):**
```json
{
  "error": "User does not have this role"
}
```

---

### Update User Roles

Replaces all user roles with a new set of roles. **Requires JWT authentication and admin role.**

**Endpoint:** `PUT /api/users/:id/roles`

**Request:**
```bash
# Set multiple roles
curl -X PUT -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_access_token" \
  -d '{"roles": ["admin", "manager"]}' \
  http://localhost:8000/api/users/user_uuid/roles

# Remove all roles (empty array)
curl -X PUT -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_access_token" \
  -d '{"roles": []}' \
  http://localhost:8000/api/users/user_uuid/roles
```

**Response:**
```json
{
  "message": "Roles updated successfully",
  "user": {
    "id": "uuid",
    "username": "johndoe",
    "roles": ["admin", "manager"]
  }
}
```

**Error Response (Invalid Roles):**
```json
{
  "error": "Invalid roles: invalid_role, another_invalid",
  "valid_roles": ["admin", "school_admin", "teacher", "student", "system", "guardian"]
}
```

---

## Group & Attendance Routes

### List Teacher's Groups

Retrieves a list of groups where the current user is a teacher. **Requires JWT authentication.**

**Endpoint:** `GET /api/groups`

**Request:**
```bash
# Login as a teacher first
curl -X POST -H "Content-Type: application/json" -d 
  "{
    \"email\": \"priya.sharma@steambuds.com\",
    \"password\": \"Password123\"
  }" http://localhost:8000/api/login

# Use the returned token to get groups
curl -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/groups
```

**Response:**
```json
[
  {
    "id": "group-uuid-1",
    "name": "Greenwood Math Champions",
    "about": "Advanced Mathematics study group for Grade 9 & 10 students",
    "grades": "9,10",
    "same_school": true,
    "created_at": "2025-12-10T10:00:00.000Z",
    "updated_at": "2025-12-10T10:00:00.000Z"
  },
  {
    "id": "group-uuid-2",
    "name": "Inter-School Science Explorers",
    "about": "Multi-school collaborative science project",
    "grades": "9,10",
    "same_school": false,
    "created_at": "2025-12-10T10:00:00.000Z",
    "updated_at": "2025-12-10T10:00:00.000Z"
  }
]
```

**Notes:**
- Only returns groups where the authenticated user is assigned as a teacher
- Teachers see different groups based on their assignments
- Empty array `[]` returned if user has no group assignments

---

### Get Group Attendance Dashboard

Retrieves comprehensive attendance data for a specific group, including:
- List of all students in the group
- Aggregate attendance statistics (present/absent/late/excused counts)
- Calendar view with daily attendance status

**Requires JWT authentication and user must be a teacher of the group.**

**Endpoint:** `GET /api/groups/:group_id/attendances`

**Request:**
```bash
curl -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/groups/group_uuid/attendances
```

**Response:**
```json
[
  {
    "user_id": "student-uuid-1",
    "steamer_id": 9000008,
    "name": "Aarav Patel",
    "stats": {
      "present": 18,
      "absent": 1,
      "late": 2,
      "excused": 1
    },
    "calendar": {
      "2025-12-09": "present",
      "2025-12-06": "late",
      "2025-12-05": "present",
      "2025-12-04": "present",
      "2025-12-03": "absent",
      "2025-12-02": "present"
    }
  },
  {
    "user_id": "student-uuid-2",
    "steamer_id": 9000009,
    "name": "Diya Reddy",
    "stats": {
      "present": 20,
      "absent": 0,
      "late": 1,
      "excused": 1
    },
    "calendar": {
      "2025-12-09": "present",
      "2025-12-06": "present",
      "2025-12-05": "present",
      "2025-12-04": "late",
      "2025-12-03": "present",
      "2025-12-02": "present"
    }
  }
]
```

**Response Fields:**
- `user_id`: Student's UUID
- `steamer_id`: Student's unique steamer ID (used for external integrations)
- `name`: Student's full name
- `stats`: Aggregate counts of each attendance status
  - `present`: Number of days marked present
  - `absent`: Number of days marked absent
  - `late`: Number of days marked late
  - `excused`: Number of days marked excused
- `calendar`: Map of dates (YYYY-MM-DD) to attendance status
  - Only includes dates where attendance was recorded
  - Sorted by date (newest first in the example)

**Notes:**
- Weekend days are excluded from attendance records
- Only shows students assigned to the group with `student` relation
- Calendar includes historical attendance (typically last 30-90 days)
- Empty calendar `{}` if no attendance recorded yet

---

### Record Attendance (Bulk)

Submits attendance records for multiple students in a group for a specific date. This endpoint supports bulk submission, allowing teachers to mark attendance for an entire class at once.

**Requires JWT authentication and user must be a teacher of the group.**

**Endpoint:** `POST /api/groups/:group_id/attendances`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_access_token" \
  -d 
  "{
  \"date\": \"2025-12-10T09:00:00Z\",
  \"attendances\": [
    { \"user_id\": \"student-uuid-1\", \"status\": \"present\" },
    { \"user_id\": \"student-uuid-2\", \"status\": \"present\" },
    { \"user_id\": \"student-uuid-3\", \"status\": \"late\" },
    { \"user_id\": \"student-uuid-4\", \"status\": \"absent\" },
    { \"user_id\": \"student-uuid-5\", \"status\": \"excused\" }
  ]
}" http://localhost:8000/api/groups/group_uuid/attendances
```

**Request Fields:**
- `date` (required): ISO 8601 datetime string representing when attendance was taken (typically class start time)
- `attendances` (required): Array of attendance records
  - `user_id` (required): Student's UUID (must be a student in the group)
  - `status` (required): One of `present`, `absent`, `late`, `excused`

**Response (Success):**
```json
{
  "message": "Attendance recorded successfully",
  "date": "2025-12-10T09:00:00.000Z",
  "records_created": 5
}
```

**Response (Validation Error):**
```json
{
  "error": "Validation failed",
  "details": [
    "Student with ID student-uuid-999 is not in this group",
    "Invalid status: 'maybe' - must be one of: present, absent, late, excused"
  ]
}
```

**Response (Unauthorized - not a group teacher):**
```json
{
  "error": "Forbidden",
  "message": "You must be a teacher of this group"
}
```

**Notes:**
- If attendance already exists for a student on the given date, it will be updated
- All students must belong to the specified group
- Date can be past or present, but typically shouldn't be future
- Valid statuses: `present`, `absent`, `late`, `excused`
- Returns error if any user_id doesn't exist or isn't a student in the group

**Example Usage - Daily Attendance Flow:**

```bash
# 1. Teacher logs in
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" 
  -d '{"email": "priya.sharma@steambuds.com", "password": "Password123"}' 
  http://localhost:8000/api/login | jq -r '.token')

# 2. Get list of teacher's groups
GROUPS=$(curl -s -H "Authorization: Bearer $TOKEN" 
  http://localhost:8000/api/groups)

# 3. Get group ID (first group)
GROUP_ID=$(echo $GROUPS | jq -r '.[0].id')

# 4. Get current attendance dashboard (to see students)
curl -s -H "Authorization: Bearer $TOKEN" 
  http://localhost:8000/api/groups/$GROUP_ID/attendances | jq

# 5. Mark today's attendance
curl -X POST -H "Content-Type: application/json" 
  -H "Authorization: Bearer $TOKEN" 
  -d "{
    \"date\": \"$(date -u +%Y-%m-%dT09:00:00Z)\",
    \"attendances\": [
      {\"user_id\": \"student-1-uuid\", \"status\": \"present\"},
      {\"user_id\": \"student-2-uuid\", \"status\": \"present\"}
    ]
  }" 
  http://localhost:8000/api/groups/$GROUP_ID/attendances
```

---

## Authentication & Authorization Notes

- **Access Token:** Short-lived (24 hours), used for API requests
- **Refresh Token:** Long-lived (30 days), used to obtain new access tokens
- **Authorization Header Format:** `Bearer <access_token>`
- Protected endpoints will return `401 Unauthorized` without a valid token
- Role-protected endpoints will return `403 Forbidden` if the authenticated user lacks the required role

### Available Roles
- **admin** - Administrator role with full access to all protected endpoints
- **school_admin** - School administrator role
- **teacher** - Teacher role for leading groups and marking attendance
- **student** - Student role for group membership and attendance tracking
- **system** - System/automated process role
- **guardian** - Guardian role for students

### Endpoint Access Summary

| Endpoint | Authentication Required | Role Required |
|----------|------------------------|---------------|
| POST /api/user | No | None |
| POST /api/login | No | None |
| POST /api/refresh | No | None |
| DELETE /api/logout | No | None |
| POST /api/hello | No | None |
| POST /api/track_visit | No | None |
| GET /api/hello | Yes | admin |
| DELETE /api/hello/:id | Yes | admin |
| GET /api/profiles | Yes | admin |
| GET /api/profiles/:id | Yes | Own Profile or admin |
| POST /api/profiles | Yes | None (User can only create one profile) |
| PUT/PATCH /api/profiles/:id | Yes | Own Profile or admin |
| DELETE /api/profiles/:id | Yes | Own Profile or admin |
| GET /api/users | Yes | admin |
| GET /api/users/:id | Yes | admin |
| POST /api/users/:id/roles | Yes | admin |
| DELETE /api/users/:id/roles/:role | Yes | admin |
| PUT /api/users/:id/roles | Yes | admin |
| GET /api/groups | Yes | None (Teacher) |
| GET /api/groups/:group_id/attendances | Yes | None (Teacher of group) |
| POST /api/groups/:group_id/attendances | Yes | None (Teacher of group) |