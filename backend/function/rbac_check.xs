function "rbac_check" {
  description = "Check whether a user has a given permission key via any of their assigned roles."

  input {
    text user_id filters=trim
    text permission_key filters=trim|lower
  }

  stack {
    db.get "rbac_permission" {
      field_name = "key"
      field_value = $input.permission_key
    } as $perm

    conditional {
      if ($perm == null) {
        return {
          value = {allowed: false, reason: "unknown_permission", matched_role_id: null}
        }
      }
    }

    db.query "rbac_user_role" {
      where = $db.rbac_user_role.user_id == $input.user_id
    } as $user_roles

    conditional {
      if (($user_roles|count) == 0) {
        return {
          value = {allowed: false, reason: "no_roles", matched_role_id: null}
        }
      }
    }

    var $matched_role_id { value = null }

    foreach ($user_roles) {
      each as $ur {
        conditional {
          if ($matched_role_id == null) {
            db.query "rbac_role_permission" {
              where = $db.rbac_role_permission.role_id == $ur.role_id && $db.rbac_role_permission.permission_id == $perm.id
              return = {type: "single"}
            } as $grant

            conditional {
              if ($grant != null) {
                var.update $matched_role_id { value = $ur.role_id }
              }
            }
          }
        }
      }
    }

    conditional {
      if ($matched_role_id == null) {
        return {
          value = {allowed: false, reason: "permission_not_granted", matched_role_id: null}
        }
      }
    }
  }

  response = {allowed: true, reason: "granted", matched_role_id: $matched_role_id}
  guid = "EULt8UpENB0ySisDKukd8ktlgNo"
}
