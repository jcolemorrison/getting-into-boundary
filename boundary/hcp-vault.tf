resource "vault_mount" "static" {
  path        = "${var.project_name}/static"
  type        = "kv"
  options     = { version = "2" }
  description = "For static secrets related to ${var.project_name}"
}