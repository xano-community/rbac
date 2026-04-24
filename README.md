# rbac

A role-based access control module for Xano. Define roles, define permissions, grant permissions to roles, assign roles to users, and then ask "can user X do Y?" from anywhere in your stack.

This is a **module**, not a full app: no frontend, no auth, no UI. Just the tables, a reusable check function, and a compact admin HTTP surface.

## What you get

- **4 tables** — `rbac_role`, `rbac_permission`, `rbac_role_permission`, `rbac_user_role`.
- **Function `rbac_check`** — returns `{ allowed, reason, matched_role_id }` for any user + permission key. Drop into any query or function for authorization checks.
- **HTTP API `rbac`** — admin endpoints to manage roles/permissions/assignments plus a check endpoint for services without XanoScript access.

## Install

```bash
npm install -g @xano/cli
xano profile:wizard

cd backend
xano workspace:push
```

Creates 4 tables, 1 function, 1 api group, and 10 endpoints.

## API surface

```
# roles
POST   /api:rbac/roles                                           { name, description? }
GET    /api:rbac/roles                                           list roles (with granted permission keys)

# permissions
POST   /api:rbac/permissions                                     { key, description? }
GET    /api:rbac/permissions                                     list permissions

# grant/revoke permissions on a role
POST   /api:rbac/roles/{role_id}/permissions                     { permission_key }
DELETE /api:rbac/roles/{role_id}/permissions/{permission_id}

# assign/revoke roles to a user (user_id is text — works with any id scheme)
POST   /api:rbac/users/{user_id}/roles                           { role_id }
DELETE /api:rbac/users/{user_id}/roles/{role_id}

# effective permissions + check
GET    /api:rbac/users/{user_id}/permissions                     { roles:[], permissions:[] }
POST   /api:rbac/check                                           { user_id, permission_key } -> { allowed, reason, matched_role_id }
```

## Usage

### 1. Seed a minimal policy

```bash
B=https://YOUR-INSTANCE.n7d.xano.io

curl -XPOST $B/api:rbac/roles -H 'Content-Type: application/json' -d '{"name":"admin"}'
curl -XPOST $B/api:rbac/roles -H 'Content-Type: application/json' -d '{"name":"editor"}'

curl -XPOST $B/api:rbac/permissions -H 'Content-Type: application/json' -d '{"key":"tickets.delete"}'
curl -XPOST $B/api:rbac/permissions -H 'Content-Type: application/json' -d '{"key":"tickets.edit"}'

curl -XPOST $B/api:rbac/roles/1/permissions -H 'Content-Type: application/json' -d '{"permission_key":"tickets.delete"}'
curl -XPOST $B/api:rbac/roles/1/permissions -H 'Content-Type: application/json' -d '{"permission_key":"tickets.edit"}'
curl -XPOST $B/api:rbac/roles/2/permissions -H 'Content-Type: application/json' -d '{"permission_key":"tickets.edit"}'

curl -XPOST $B/api:rbac/users/42/roles -H 'Content-Type: application/json' -d '{"role_id":1}'
curl -XPOST $B/api:rbac/users/77/roles -H 'Content-Type: application/json' -d '{"role_id":2}'
```

### 2. Check from another service

```bash
curl -XPOST $B/api:rbac/check \
  -H 'Content-Type: application/json' \
  -d '{"user_id":"42","permission_key":"tickets.delete"}'
# -> {"allowed":true,"reason":"granted","matched_role_id":1}
```

Possible `reason` values: `granted`, `no_roles`, `permission_not_granted`, `unknown_permission`.

### 3. Gate a XanoScript endpoint

```xs
query "tickets/{ticket_id}" verb=DELETE {
  api_group = "HelpDesk"
  auth = "user"

  input {
    int ticket_id { table = "hd_ticket" }
  }

  stack {
    function.run "rbac_check" {
      input = {
        user_id       : $auth.id|to_text,
        permission_key: "tickets.delete"
      }
    } as $rbac

    precondition ($rbac.allowed) {
      error_type = "accessdenied"
      error = "tickets.delete required"
    }

    db.del "hd_ticket" { field_name = "id"  field_value = $input.ticket_id }
  }

  response = { success: true }
}
```

## Schema

- **`rbac_role`** — id, created_at, `name` (unique), description
- **`rbac_permission`** — id, created_at, `key` (unique, lowercase, e.g. `tickets.delete`), description
- **`rbac_role_permission`** — join table
- **`rbac_user_role`** — `user_id` (text) + `role_id`. Text user_id lets you plug in any id scheme — int PKs, UUIDs, external IDs

## Design notes

- **Text user IDs.** No FK to a `user` table — the module doesn't assume you have one or what its PK type is. Convert your int `$auth.id` with `|to_text` at the call site.
- **Union of roles.** A user's effective permissions are the union across all their assigned roles.
- **Idempotent assignments.** Granting a permission that's already granted, or assigning a role that's already assigned, is a no-op.
- **Dotted permission keys are a convention, not a requirement.** `tickets.delete`, `billing.read`, `admin.*` — whatever grep-friendly scheme you like.

## License

MIT.
