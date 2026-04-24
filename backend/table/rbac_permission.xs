table "rbac_permission" {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    text key filters=trim|lower
    text description?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree|unique", field: [{name: "key", op: "asc"}]}
  ]
  guid = "cA8wVyq85CxrQVeD0kXCmj7D91w"
}
