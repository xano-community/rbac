// List a user's effective roles and the union of permissions granted via them.
query "users/{user_id}/permissions" verb=GET {
  api_group = "Rbac"

  input {
    text user_id filters=trim
  }

  stack {
    db.query "rbac_user_role" {
      where = $db.rbac_user_role.user_id == $input.user_id
    } as $user_roles

    var $role_names { value = [] }
    var $perm_keys { value = [] }

    foreach ($user_roles) {
      each as $ur {
        db.get "rbac_role" {
          field_name = "id"
          field_value = $ur.role_id
        } as $role

        conditional {
          if ($role != null) {
            var.update $role_names {
              value = $role_names|push:$role.name
            }
          }
        }

        db.query "rbac_role_permission" {
          where = $db.rbac_role_permission.role_id == $ur.role_id
        } as $rps

        foreach ($rps) {
          each as $rp {
            db.get "rbac_permission" {
              field_name = "id"
              field_value = $rp.permission_id
            } as $p

            conditional {
              if ($p != null) {
                var.update $perm_keys {
                  value = $perm_keys|push:$p.key
                }
              }
            }
          }
        }
      }
    }
  }

  response = {
    user_id    : $input.user_id,
    roles      : $role_names|unique,
    permissions: $perm_keys|unique
  }
  guid = "Fgp75KNgGQgJLcabDLGTZ9ttut4"
}
