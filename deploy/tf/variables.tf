variable "tenancy_ocid" {
  type = string
}

variable "region" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "cert_fullchain" {
  type = string
}

variable "cert_private_key" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "project_name" {
  type    = string
  default = "fsdr"
}

variable "instance_shape" {
  default = "VM.Standard.E4.Flex"
}

variable "app_node_count" {
  default = "1"
}

variable "artifacts_par_expiration_in_days" {
  type    = number
  default = 7
}

variable "region_peer" {
  type = string
}

variable "autonomous_database_db_workload" {
  type    = string
  default = "OLTP"
}

variable "autonomous_database_db_license" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "autonomous_database_db_whitelisted_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"] # Don't do this in prod
}

variable "autonomous_database_cpu_core_count" {
  type    = number
  default = 1
}

variable "autonomous_database_data_storage_size_in_tbs" {
  type    = number
  default = 1
}
