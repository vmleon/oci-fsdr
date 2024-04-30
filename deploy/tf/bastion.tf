
resource "oci_bastion_bastion" "app_subnet_bastion" {
    bastion_type = "standard"
    compartment_id = var.compartment_ocid
    target_subnet_id = oci_core_subnet.app_subnet_primary.id

    client_cidr_block_allow_list = [local.anywhere]
    name = "app_subnet_${local.project_name}_${local.deploy_id}"

    depends_on = [time_sleep.wait_for_app]
}

resource "oci_bastion_bastion" "app_subnet_bastion_standby" {
    provider = oci.peer
    bastion_type = "standard"
    compartment_id = var.compartment_ocid
    target_subnet_id = oci_core_subnet.app_subnet_standby.id

    client_cidr_block_allow_list = [local.anywhere]
    name = "app_subnet_stndby_${local.project_name}_${local.deploy_id}"

    depends_on = [time_sleep.wait_for_app_stdby]
}