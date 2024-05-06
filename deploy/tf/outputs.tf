output "project_deployment_name" {
  value = "${var.project_name}${random_string.deploy_id.result}"
}

# output "load_balancer" {
#   value = oci_core_public_ip.reserved_ip.ip_address
# }

# output "backend_instances" {
#   value = oci_core_instance.backend[*].private_ip
# }

# output "ssh_bastion_session_backend" {
#   value = oci_bastion_session.backend_session.ssh_metadata.command
# }

output "db_service_primary" {
  value = "${local.project_name}${local.deploy_id}"
}

output "db_password_primary" {
  value = random_password.adb_admin_password_primary.result
  sensitive = true
}

output "db_service_standby" {
  value = "${local.project_name}${local.deploy_id}"
}

output "db_password_standby" {
  value = random_password.adb_admin_password_standby.result
  sensitive = true
}