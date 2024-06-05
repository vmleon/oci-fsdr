output "db_service_name" {
  value = "${local.project_name}${local.deploy_id}"
}

output "db_password_primary" {
  value     = random_password.adb_admin_password_primary.result
  sensitive = true
}

output "load_balancer" {
  value = oci_core_public_ip.reserved_ip.ip_address
}

output "load_balancer_standby" {
  value = oci_core_public_ip.reserved_ip_standby.ip_address
}

output "bastion_id" {
  value = oci_bastion_bastion.app_subnet_bastion.id
}

output "bastion_standby_id" {
  value = oci_bastion_bastion.app_subnet_bastion_standby.id
}

output "instance_app_ids" {
  sensitive = true
  value = {
    for key, value in local.list_app_instances : key => oci_core_instance.app[key].id
  }
}

output "instance_app_stdby_ids" {
  sensitive = true
  value = {
    for key, value in local.list_app_stdby_instances : key => oci_core_instance.app_stdby[key].id
  }
}

output "wallet_par_full_path" {
  value = oci_objectstorage_preauthrequest.wallet_par.full_path
}

output "wallet_par_full_path_standby" {
  value = oci_objectstorage_preauthrequest.wallet_par_standby.full_path
}