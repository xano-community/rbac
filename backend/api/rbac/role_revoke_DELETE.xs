// Revoke a permission from a role.
query "roles/{role_id}/permissions/{permission_id}" verb=DELETE {
  api_group = "Rbac"

  input {
    int role_id {
      table = "rbac_role"
    }
    int permission_id {
      table = "rbac_permission"
    }
  }

  stack {
    db.query "rbac_role_permission" {
      where = $db.rbac_role_permission.role_id == $input.role_id && $db.rbac_role_permission.permission_id == $input.permission_id
      return = {type: "single"}
    } as $assignment

    conditional {
      if ($assignment != null) {
        db.del "rbac_role_permission" {
          field_name = "id"
          field_value = $assignment.id
        }
      }
    }
  }

  response = {success: true}
  guid = "-3NgfIJXX1XwdFZGYgWGwJNGnrA"
}
