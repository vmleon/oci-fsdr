resource "random_password" "adb_admin_password_standby" {
  length           = 16
  special          = true
  min_numeric      = 3
  min_special      = 3
  min_lower        = 3
  min_upper        = 3
  override_special = "()-_[]{}?"
}

resource "oci_database_autonomous_database" "adb_standby" {
  provider = oci.peer
  compartment_id = var.compartment_ocid
  db_name        = "${local.project_name}${local.deploy_id}"

  #Optional
  admin_password              = random_password.adb_admin_password_standby.result
  cpu_core_count              = var.autonomous_database_cpu_core_count
  data_storage_size_in_tbs    = var.autonomous_database_data_storage_size_in_tbs
  db_workload                 = var.autonomous_database_db_workload
  display_name                = "${local.project_name}${local.deploy_id}"
  is_mtls_connection_required = true
  whitelisted_ips             = var.autonomous_database_db_whitelisted_ips
  is_auto_scaling_enabled     = true
  license_model               = var.autonomous_database_db_license
}

# For mTLS and Wallet connectivity consider the following code

resource "oci_database_autonomous_database_wallet" "adb_wallet_standby" {
  provider = oci.peer
  autonomous_database_id = oci_database_autonomous_database.adb_standby.id
  password               = random_password.adb_admin_password_standby.result
  base64_encode_content  = "true"
}

resource "local_file" "adb_wallet_standby_file" {
  content_base64 = oci_database_autonomous_database_wallet.adb_wallet_standby.content
  filename       = "${path.module}/generated/wallet_standby.zip"
}