provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
}

provider "oci" {
  alias        = "home"
  tenancy_ocid = var.tenancy_ocid
  region       = lookup(data.oci_identity_regions.home.regions[0], "name")
}

provider "oci" {
  alias        = "peer"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region_peer
}
