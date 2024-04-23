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

# variable "backend_artifact_url" {
#   type = string
# }

# variable "ansible_backend_artifact_url" {
#   type = string
# }

# variable "instance_shape" {
#   default = "VM.Standard.E4.Flex"
# }

# variable "backend_node_count" {
#   default = "1"
# }

variable "artifacts_par_expiration_in_days" {
  type    = number
  default = 7
}
