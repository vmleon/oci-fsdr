
resource "oci_database_autonomous_database" "adb_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  source         = "CROSS_REGION_DATAGUARD"
  source_id      = oci_database_autonomous_database.adb.id
  db_name        = oci_database_autonomous_database.adb.db_name

  depends_on = [ oci_database_autonomous_database.adb ]
}

resource "oci_database_autonomous_database_wallet" "adb_wallet_standby" {
  provider               = oci.peer
  autonomous_database_id = oci_database_autonomous_database.adb_standby.id
  password               = random_password.adb_admin_password_primary.result
  base64_encode_content  = "true"
}

resource "local_file" "adb_wallet_standby_file" {
  content_base64 = oci_database_autonomous_database_wallet.adb_wallet_standby.content
  filename       = "${path.module}/generated/wallet_standby.zip"
}
