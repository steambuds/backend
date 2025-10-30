# API Curl Requests

## User Registration

Creates a new user.

```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "username": "testuser",
  "email": "test@example.com",
  "password": "Password123"
}' http://localhost:3000/api/user
```

## User Login

Logs in a user and returns a JWT token and a refresh token.

```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "email": "test@example.com",
  "password": "Password123"
}' http://localhost:3000/api/login
```

## User Logout

Logs out a user by invalidating the refresh token. Replace `"your_refresh_token"` with the actual refresh token obtained from the login response.

```bash

curl -X DELETE -H "Content-Type: application/json" -d '{
  "refresh_token": "your_refresh_token"
}' http://localhost:3000/api/logout
```

## Get All Hellos

Retrieves a list of all "hello" records.

```bash
curl http://localhost:3000/api/hello
```

## Create a Hello

Creates a new "hello" record.

```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "hello": {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "description": "This is a test.",
    "subject": "Test",
    "category": "General"
  }
}' http://localhost:3000/api/hello
```
