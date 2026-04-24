// Assign a role to a user. Idempotent.
query "users/{user_id}/roles" verb=POST {
  api_group = "Rbac"

  input {
    text user_id filters=trim
    int role_id {
      table = "rbac_role"
    }
  }

  stack {
    db.get "rbac_role" {
      field_name = "id"
      field_value = $input.role_id
    } as $role

    precondition ($role != null) {
      error_type = "notfound"
      error = "Role not found"
    }

    db.query "rbac_user_role" {
      where = $db.rbac_user_role.user_id == $input.user_id && $db.rbac_user_role.role_id == $input.role_id
      return = {type: "single"}
    } as $existing

    conditional {
      if ($existing == null) {
        db.add "rbac_user_role" {
          data = {
            user_id: $input.user_id,
            role_id: $input.role_id
          }
        } as $assignment
      }
    }
  }

  response = {success: true, user_id: $input.user_id, role: $role.name}
  guid = "4wPiAYe9RPuYhIoMjzcjEeWtD3U"
}
