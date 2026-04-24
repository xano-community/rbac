// Check whether a user has a permission. Backed by the rbac_check function.
query "check" verb=POST {
  api_group = "Rbac"

  input {
    text user_id filters=trim
    text permission_key filters=trim|lower
  }

  stack {
    function.run "rbac_check" {
      input = {
        user_id       : $input.user_id,
        permission_key: $input.permission_key
      }
    } as $result
  }

  response = $result
  guid = "S3dZ3ZqO7lCay0uARuFP9gCDKX0"
}
