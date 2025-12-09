# API Documentation

## Authentication Routes

### User Registration

Creates a new user account.

**Endpoint:** `POST /api/user`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "username": "testuser",
  "email": "test@example.com",
  "password": "Password123"
}' http://localhost:8000/api/user
```

**Response:**
```json
{
  "id": "uuid",
  "username": "testuser",
  "email": "test@example.com"
}
```

---

### User Login

Logs in a user and returns a JWT access token and a refresh token.

**Endpoint:** `POST /api/login`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "email": "ghanshyam@steambuds.com",
  "password": "Admin123"
}' http://localhost:8000/api/login
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
curl -X DELETE -H "Content-Type: application/json" -d '{
  "refresh_token": "your_refresh_token"
}' http://localhost:8000/api/logout
```

**Response:** `204 No Content`

---

### Refresh Access Token

Generates a new access token using a valid refresh token.

**Endpoint:** `POST /api/refresh`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "refresh_token": "your_refresh_token"
}' http://localhost:8000/api/refresh
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
curl -X POST -H "Content-Type: application/json" -d '{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "description": "This is a test message.",
  "mobile_number": "+1234567890",
  "category": "General"
}' http://localhost:8000/api/hello
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
    "user_id": "uuid",
    "user_type": "student",
    "bio": "A passionate student.",
    "avatar_url": "http://example.com/avatar.jpg",
    "phone": "+1234567890",
    "address": "123 Main St",
    "date_of_birth": "2000-01-01",
    "subjects_taught": null,
    "years_experience": null,
    "qualification": null,
    "grade_level": "10",
    "enrollment_date": "2023-09-01",
    "parent_contact": "parent@example.com",
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
  "user_id": "uuid",
  "user_type": "student",
  "bio": "A passionate student.",
  "avatar_url": "http://example.com/avatar.jpg",
  "phone": "+1234567890",
  "address": "123 Main St",
  "date_of_birth": "2000-01-01",
    "subjects_taught": null,
    "years_experience": null,
    "qualification": null,
    "grade_level": "10",
    "enrollment_date": "2023-09-01",
    "parent_contact": "parent@example.com",
    "created_at": "2025-11-01T10:00:00.000Z",
    "updated_at": "2025-11-01T10:00:00.000Z"
}
```

---

### Create a Profile

Creates a new user profile. **Requires JWT authentication. Each user can only have one profile.**

**Endpoint:** `POST /api/profiles`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer your_access_token" -d '{
  "user_type": "student",
  "bio": "A passionate student.",
  "avatar_url": "http://example.com/avatar.jpg",
  "phone": "+1234567890",
  "address": "123 Main St",
  "date_of_birth": "2000-01-01",
  "grade_level": "10",
  "enrollment_date": "2023-09-01",
  "parent_contact": "parent@example.com"
}' http://localhost:8000/api/profiles
```

**Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "user_type": "student",
  "bio": "A passionate student.",
  "avatar_url": "http://example.com/avatar.jpg",
  "phone": "+1234567890",
  "address": "123 Main St",
  "date_of_birth": "2000-01-01",
  "subjects_taught": null,
  "years_experience": null,
  "qualification": null,
  "grade_level": "10",
  "enrollment_date": "2023-09-01",
  "parent_contact": "parent@example.com",
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
curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer your_access_token" -d '{
  "bio": "An updated bio for the student."
}' http://localhost:8000/api/profiles/uuid-here
```

**Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "user_type": "student",
  "bio": "An updated bio for the student.",
  "avatar_url": "http://example.com/avatar.jpg",
  "phone": "+1234567890",
  "address": "123 Main St",
  "date_of_birth": "2000-01-01",
  "subjects_taught": null,
  "years_experience": null,
  "qualification": null,
  "grade_level": "10",
  "enrollment_date": "2023-09-01",
  "parent_contact": "parent@example.com",
  "created_at": "2025-11-01T10:00:00.000Z",
  "updated_at": "2025-11-01T10:00:00.000Z"
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

## Admin Routes

### List All Users

Retrieves a paginated list of all users with their profiles and roles. Supports search and filtering. **Requires JWT authentication and admin role.**

**Endpoint:** `GET /api/admin/users`

**Query Parameters:**
- `search` (optional): Fuzzy search on email and phone number
- `role` (optional): Filter by user role (admin, manager, server_machine)
- `profile_type` (optional): Filter by profile type (teacher, student)
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Records per page (default: 20, max: 100)

**Request:**
```bash
# Get all users with pagination
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/admin/users?page=1&per_page=20

# Search users by email or phone
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/admin/users?search=john@example.com

# Filter by role
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/admin/users?role=admin

# Filter by profile type
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/admin/users?profile_type=teacher

# Combined filters and search
curl -X GET -H "Authorization: Bearer your_access_token" \
  "http://localhost:8000/api/admin/users?search=john&role=manager&page=1&per_page=10"
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
      "roles": ["admin", "manager"],
      "profile": {
        "user_type": "teacher",
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

**Endpoint:** `GET /api/admin/users/:id`

**Request:**
```bash
curl -X GET -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/admin/users/user_uuid
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
    "user_type": "teacher",
    "bio": "Experienced mathematics teacher",
    "avatar_url": "https://example.com/avatar.jpg",
    "phone": "+1234567890",
    "address": "123 Main St, City, Country",
    "date_of_birth": "1985-05-15",
    "subjects_taught": "Mathematics, Physics",
    "years_experience": 10,
    "qualification": "PhD in Mathematics"
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

**Endpoint:** `POST /api/admin/users/:id/roles`

**Request:**
```bash
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_access_token" \
  -d '{"role": "manager"}' \
  http://localhost:8000/api/admin/users/user_uuid/roles
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
  "error": "Invalid role. Valid roles are: admin, server_machine, manager"
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

**Endpoint:** `DELETE /api/admin/users/:id/roles/:role`

**Request:**
```bash
curl -X DELETE -H "Authorization: Bearer your_access_token" \
  http://localhost:8000/api/admin/users/user_uuid/roles/manager
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

**Endpoint:** `PUT /api/admin/users/:id/roles`

**Request:**
```bash
# Set multiple roles
curl -X PUT -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_access_token" \
  -d '{"roles": ["admin", "manager"]}' \
  http://localhost:8000/api/admin/users/user_uuid/roles

# Remove all roles (empty array)
curl -X PUT -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_access_token" \
  -d '{"roles": []}' \
  http://localhost:8000/api/admin/users/user_uuid/roles
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
  "valid_roles": ["admin", "server_machine", "manager"]
}
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
- **manager** - Manager role with elevated permissions
- **server_machine** - Server/machine role for automated processes

### Endpoint Access Summary

| Endpoint | Authentication Required | Role Required |
|----------|------------------------|---------------|
| POST /api/user | No | None |
| POST /api/login | No | None |
| POST /api/refresh | No | None |
| DELETE /api/logout | No | None |
| POST /api/hello | No | None |
| GET /api/hello | Yes | admin |
| DELETE /api/hello/:id | Yes | admin |
| GET /api/profiles | Yes | admin |
| GET /api/profiles/:id | Yes | Own Profile or admin |
| POST /api/profiles | Yes | None (User can only create one profile) |
| PUT/PATCH /api/profiles/:id | Yes | Own Profile or admin |
| DELETE /api/profiles/:id | Yes | Own Profile or admin |
| GET /api/admin/users | Yes | admin |
| GET /api/admin/users/:id | Yes | admin |
| POST /api/admin/users/:id/roles | Yes | admin |
| DELETE /api/admin/users/:id/roles/:role | Yes | admin |
| PUT /api/admin/users/:id/roles | Yes | admin |
