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
}' http://localhost:3000/api/user
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
  "email": "test@example.com",
  "password": "Password123"
}' http://localhost:3000/api/login
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
}' http://localhost:3000/api/logout
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
}' http://localhost:3000/api/refresh
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
  http://localhost:3000/api/hello
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
}' http://localhost:3000/api/hello
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
  http://localhost:3000/api/hello/uuid-here
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
