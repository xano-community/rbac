// List all permissions.
query "permissions" verb=GET {
  api_group = "Rbac"

  input {}

  stack {
    db.query "rbac_permission" {
      sort = {key: "asc"}
    } as $perms
  }

  response = $perms
  guid = "yz5Q37qayHS7UK_ptaZaezPd3Ug"
}
