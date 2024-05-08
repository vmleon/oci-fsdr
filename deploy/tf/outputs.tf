output "db_service_name" {
  value = "${local.project_name}${local.deploy_id}"
}

output "db_password_primary" {
  value = random_password.adb_admin_password_primary.result
  sensitive = true
}

output "db_password_standby" {
  value = random_password.adb_admin_password_standby.result
  sensitive = true
}

output "load_balancer" {
  value = oci_core_public_ip.reserved_ip.ip_address
}

output "load_balancer_standby" {
  value = oci_core_public_ip.reserved_ip_standby.ip_address
}