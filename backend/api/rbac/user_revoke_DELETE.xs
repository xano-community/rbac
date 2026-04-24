// Revoke a role from a user.
query "users/{user_id}/roles/{role_id}" verb=DELETE {
  api_group = "Rbac"

  input {
    text user_id filters=trim
    int role_id {
      table = "rbac_role"
    }
  }

  stack {
    db.query "rbac_user_role" {
      where = $db.rbac_user_role.user_id == $input.user_id && $db.rbac_user_role.role_id == $input.role_id
      return = {type: "single"}
    } as $assignment

    conditional {
      if ($assignment != null) {
        db.del "rbac_user_role" {
          field_name = "id"
          field_value = $assignment.id
        }
      }
    }
  }

  response = {success: true}
  guid = "5unI9zyg1ls1IwIdTRb9hsrpJAY"
}
