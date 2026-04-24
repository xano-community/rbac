table "rbac_user_role" {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    text user_id filters=trim
    int role_id {
      table = "rbac_role"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "user_id"}]}
    {type: "btree", field: [{name: "role_id"}]}
  ]
  guid = "68wB-CT1fNU86V_TjPk1kF4YTq0"
}
