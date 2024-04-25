resource "oci_core_virtual_network" "vcn_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["20.0.0.0/16"]
  display_name   = "VCN Standby ${local.project_name} ${local.deploy_id}"
  dns_label      = "standby${local.project_name}${local.deploy_id}"
}

resource "oci_core_drg" "drg_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  display_name   = "DRG Standby ${local.project_name} ${local.deploy_id}"
}

resource "oci_core_drg_attachment" "drg_attachment_standby" {
  provider     = oci.peer
  drg_id       = oci_core_drg.drg_standby.id
  vcn_id       = oci_core_virtual_network.vcn_standby.id
  display_name = "Standby ${local.project_name} ${local.deploy_id}"
}

resource "oci_core_remote_peering_connection" "remote_peering_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  drg_id         = oci_core_drg.drg_standby.id
  display_name   = "Standby ${local.project_name} ${local.deploy_id}"
}

resource "oci_core_internet_gateway" "ig_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  display_name   = "ig_standby_${local.project_name}_${local.deploy_id}"
  vcn_id         = oci_core_virtual_network.vcn_standby.id
}

resource "oci_core_nat_gateway" "nat_gateway_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_standby.id
  display_name   = "nat_standby_${local.project_name}_${local.deploy_id}"
}

resource "oci_core_default_route_table" "default_route_table" {
  provider                   = oci.peer
  manage_default_resource_id = oci_core_virtual_network.vcn_standby.default_route_table_id
  display_name               = "DefaultRouteTableStandby"

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig_standby.id
  }
}

resource "oci_core_route_table" "route_private_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_standby.id
  display_name   = "route_private_standby"

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway_standby.id
  }
}

resource "oci_core_subnet" "publicsubnet_standby" {
  provider          = oci.peer
  cidr_block        = "20.0.1.0/24"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn_standby.id
  display_name      = "public_subnet_standby_${local.project_name}_${local.deploy_id}"
  dns_label         = "publicstandby"
  security_list_ids = [oci_core_virtual_network.vcn_standby.default_security_list_id, oci_core_security_list.public_http_seclist_standby.id]
  route_table_id    = oci_core_virtual_network.vcn_standby.default_route_table_id
  dhcp_options_id   = oci_core_virtual_network.vcn_standby.default_dhcp_options_id
}

resource "oci_core_subnet" "app_subnet_standby" {
  provider                   = oci.peer
  cidr_block                 = "20.0.2.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn_standby.id
  display_name               = "app_subnet_standby_${local.project_name}_${local.deploy_id}"
  dns_label                  = "appstandby"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_virtual_network.vcn_standby.default_security_list_id, oci_core_security_list.app_seclist_standby.id]
  route_table_id             = oci_core_route_table.route_private_standby.id
  dhcp_options_id            = oci_core_virtual_network.vcn_standby.default_dhcp_options_id
}

resource "oci_core_subnet" "db_subnet_standby" {
  provider                   = oci.peer
  cidr_block                 = "20.0.3.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn_standby.id
  display_name               = "db_subnet_standby_${local.project_name}_${local.deploy_id}"
  dns_label                  = "dbstandby"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_virtual_network.vcn_standby.default_security_list_id, oci_core_security_list.db_seclist_standby.id]
  route_table_id             = oci_core_route_table.route_private_standby.id
  dhcp_options_id            = oci_core_virtual_network.vcn_standby.default_dhcp_options_id
}

resource "oci_core_security_list" "public_http_seclist_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_standby.id
  display_name   = "HTTP Security List Standby"

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

resource "oci_core_security_list" "app_seclist_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_standby.id
  display_name   = "App Security List"

  ingress_security_rules {
    protocol  = local.tcp
    source    = oci_core_subnet.publicsubnet_standby.cidr_block
    stateless = false

    tcp_options {
      min = 8080
      max = 8080
    }
  }
}

resource "oci_core_security_list" "db_seclist_standby" {
  provider       = oci.peer
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_standby.id
  display_name   = "DB Security List Standby"

  ingress_security_rules {
    protocol  = local.tcp
    source    = oci_core_subnet.app_subnet_standby.cidr_block
    stateless = false

    tcp_options {
      min = 1521
      max = 1521
    }
  }
}
