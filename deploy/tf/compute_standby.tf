locals {
  list_app_stdby_instances = toset([for n in range(var.app_node_count) : "appstby${n}"])
  backend_standby_cloud_init_content = templatefile("${path.module}/userdata/backend_bootstrap.tftpl", {
    backend_jar_par_full_path     = oci_objectstorage_preauthrequest.backend_artifact_par_standby.full_path
    ansible_backend_par_full_path = oci_objectstorage_preauthrequest.ansible_backend_artifact_par_standby.full_path
    wallet_par_full_path          = oci_objectstorage_preauthrequest.wallet_par_standby.full_path
    region_code_name              = var.region_peer
    db_service                    = "${local.project_name}${local.deploy_id}"
    db_password                   = random_password.adb_admin_password_standby.result
  })
}

data "oci_core_images" "ol8_images_peer" {
  provider                 = oci.peer
  compartment_id           = var.compartment_ocid
  shape                    = var.instance_shape
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "app_stdby" {
  provider = oci.peer
  for_each = local.list_app_stdby_instances
  availability_domain = lookup(
    data.oci_identity_availability_domains.ads_peer.availability_domains[
    index(tolist(local.list_app_stdby_instances), each.value) % 3],
  "name")
  compartment_id = var.compartment_ocid
  display_name   = "${each.value}_${local.project_name}_${local.deploy_id}"
  shape          = var.instance_shape

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(local.backend_standby_cloud_init_content)
  }

  agent_config {
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }

  shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.app_subnet_standby.id
    assign_public_ip          = false
    display_name              = each.value
    assign_private_dns_record = true
    hostname_label            = each.value
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ol8_images_peer.images[0].id
  }

  timeouts {
    create = "60m"
  }
}

resource "time_sleep" "wait_for_app_stdby" {
  depends_on      = [oci_core_instance.app_stdby]
  create_duration = "2m"
}
