// List all roles with their granted permission keys.
query "roles" verb=GET {
  api_group = "Rbac"

  input {}

  stack {
    db.query "rbac_role" {
      sort = {name: "asc"}
    } as $roles

    var $enriched { value = [] }

    foreach ($roles) {
      each as $role {
        db.query "rbac_role_permission" {
          where = $db.rbac_role_permission.role_id == $role.id
        } as $rps

        var $perm_keys { value = [] }

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

        var.update $enriched {
          value = $enriched|push:($role|set:"permissions":$perm_keys)
        }
      }
    }
  }

  response = $enriched
  guid = "0PMT4e9eFaLyq-MEyyYZMgnr0uU"
}
