// Create a new permission.
query "permissions" verb=POST {
  api_group = "Rbac"

  input {
    text key filters=trim|lower
    text description? filters=trim
  }

  stack {
    db.get "rbac_permission" {
      field_name = "key"
      field_value = $input.key
    } as $existing

    precondition ($existing == null) {
      error_type = "inputerror"
      error = "Permission already exists"
    }

    db.add "rbac_permission" {
      data = {
        key        : $input.key,
        description: $input.description
      }
    } as $perm
  }

  response = $perm
  guid = "eCDetxvgQXD1ARmnUFa4TW--Hks"
}
