table "rbac_role" {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    text name filters=trim
    text description?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree|unique", field: [{name: "name", op: "asc"}]}
  ]
  guid = "yuNfXaSv6W3f9y9RaY9tGDtBYzE"
}
