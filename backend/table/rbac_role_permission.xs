table "rbac_role_permission" {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    int role_id {
      table = "rbac_role"
    }
    int permission_id {
      table = "rbac_permission"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "role_id"}]}
    {type: "btree", field: [{name: "permission_id"}]}
  ]
  guid = "kMQo49ymo7DyKGDYalK-E6rSpHI"
}
