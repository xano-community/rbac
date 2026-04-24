// Create a new role.
query "roles" verb=POST {
  api_group = "Rbac"

  input {
    text name filters=trim
    text description? filters=trim
  }

  stack {
    db.get "rbac_role" {
      field_name = "name"
      field_value = $input.name
    } as $existing

    precondition ($existing == null) {
      error_type = "inputerror"
      error = "Role already exists"
    }

    db.add "rbac_role" {
      data = {
        name       : $input.name,
        description: $input.description
      }
    } as $role
  }

  response = $role
  guid = "6EJfhHH8WGZOWJdIu_6qS9t73Ko"
}
