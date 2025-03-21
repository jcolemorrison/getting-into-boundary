resource "vault_mount" "static" {
  path        = "${var.project_name}/static"
  type        = "kv"
  options     = { version = "2" }
  description = "For static secrets related to ${var.project_name}"
}

resource "vault_kv_secret_v2" "postgres" {
  mount               = vault_mount.static.path
  name                = local.database_name
  delete_all_versions = true

  data_json = <<EOT
{
  "username": "${local.database_username}",
  "password": "${local.database_password}"
}
EOT
}

data "vault_kv_secret_v2" "postgres" {
  mount = vault_kv_secret_v2.postgres.mount
  name  = vault_kv_secret_v2.postgres.name
}