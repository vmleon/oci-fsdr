resource "oci_core_virtual_network" "vcn_primary" {
  provider       = oci
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "VCN Primary ${local.project_name} ${local.deploy_id}"
  dns_label      = "primary${local.project_name}${local.deploy_id}"
}

resource "oci_core_drg" "drg_primary" {
  compartment_id = var.compartment_ocid
  display_name   = "DRG Primary ${local.project_name} ${local.deploy_id}"
}

resource "oci_core_drg_attachment" "drg_primary_attachment" {
  drg_id       = oci_core_drg.drg_primary.id
  vcn_id       = oci_core_virtual_network.vcn_primary.id
  display_name = "Primary ${local.project_name} ${local.deploy_id}"
}

resource "oci_core_remote_peering_connection" "remote_peering_primary" {
  compartment_id   = var.compartment_ocid
  drg_id           = oci_core_drg.drg_primary.id
  display_name     = "Primary ${local.project_name} ${local.deploy_id}"
  peer_id          = oci_core_remote_peering_connection.remote_peering_standby.id
  peer_region_name = var.region_peer
}

resource "oci_core_internet_gateway" "ig_primary" {
  compartment_id = var.compartment_ocid
  display_name   = "ig_${local.project_name}_${local.deploy_id}"
  vcn_id         = oci_core_virtual_network.vcn_primary.id
}

resource "oci_core_nat_gateway" "nat_gateway_primary" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_primary.id
  display_name   = "nat_${local.project_name}_${local.deploy_id}"
}

resource "oci_core_default_route_table" "default_route_table_primary" {
  manage_default_resource_id = oci_core_virtual_network.vcn_primary.default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig_primary.id
  }
}

resource "oci_core_route_table" "route_private_primary" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_primary.id
  display_name   = "route_private"

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway_primary.id
  }
}

resource "oci_core_subnet" "publicsubnet_primary" {
  cidr_block        = "10.0.1.0/24"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn_primary.id
  display_name      = "public_subnet_${local.project_name}_${local.deploy_id}"
  dns_label         = "public"
  security_list_ids = [oci_core_virtual_network.vcn_primary.default_security_list_id, oci_core_security_list.public_http_seclist_primary.id]
  route_table_id    = oci_core_virtual_network.vcn_primary.default_route_table_id
  dhcp_options_id   = oci_core_virtual_network.vcn_primary.default_dhcp_options_id
}

resource "oci_core_subnet" "app_subnet_primary" {
  cidr_block                 = "10.0.2.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn_primary.id
  display_name               = "app_subnet_${local.project_name}_${local.deploy_id}"
  dns_label                  = "app"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_virtual_network.vcn_primary.default_security_list_id, oci_core_security_list.app_seclist_primary.id]
  route_table_id             = oci_core_route_table.route_private_primary.id
  dhcp_options_id            = oci_core_virtual_network.vcn_primary.default_dhcp_options_id
}

resource "oci_core_subnet" "db_subnet_primary" {
  cidr_block                 = "10.0.3.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn_primary.id
  display_name               = "db_subnet_${local.project_name}_${local.deploy_id}"
  dns_label                  = "db"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_virtual_network.vcn_primary.default_security_list_id, oci_core_security_list.db_seclist_primary.id]
  route_table_id             = oci_core_route_table.route_private_primary.id
  dhcp_options_id            = oci_core_virtual_network.vcn_primary.default_dhcp_options_id
}

resource "oci_core_security_list" "public_http_seclist_primary" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_primary.id
  display_name   = "HTTP Security List"

  ingress_security_rules {
    protocol  = local.tcp
    source    = local.anywhere
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol  = local.tcp
    source    = local.anywhere
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

}

resource "oci_core_security_list" "app_seclist_primary" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_primary.id
  display_name   = "App Security List"

  ingress_security_rules {
    protocol  = local.tcp
    source    = oci_core_subnet.publicsubnet_primary.cidr_block
    stateless = false

    tcp_options {
      min = 8080
      max = 8080
    }
  }
}

resource "oci_core_security_list" "db_seclist_primary" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_primary.id
  display_name   = "DB Security List"

  ingress_security_rules {
    protocol  = local.tcp
    source    = oci_core_subnet.app_subnet_primary.cidr_block
    stateless = false

    tcp_options {
      min = 1521
      max = 1521
    }
  }
}
