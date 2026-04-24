// Grant a permission to a role. Idempotent.
query "roles/{role_id}/permissions" verb=POST {
  api_group = "Rbac"

  input {
    int role_id {
      table = "rbac_role"
    }
    text permission_key filters=trim|lower
  }

  stack {
    db.get "rbac_permission" {
      field_name = "key"
      field_value = $input.permission_key
    } as $perm

    precondition ($perm != null) {
      error_type = "notfound"
      error = "Permission not found"
    }

    db.query "rbac_role_permission" {
      where = $db.rbac_role_permission.role_id == $input.role_id && $db.rbac_role_permission.permission_id == $perm.id
      return = {type: "single"}
    } as $existing

    conditional {
      if ($existing == null) {
        db.add "rbac_role_permission" {
          data = {
            role_id      : $input.role_id,
            permission_id: $perm.id
          }
        } as $assignment
      }
    }
  }

  response = {success: true, role_id: $input.role_id, permission: $perm.key}
  guid = "IKRFzeA-9ycsMX1jrzAGfNC8RtM"
}
