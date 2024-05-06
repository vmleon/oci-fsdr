resource "oci_objectstorage_bucket" "logs_bucket" {
  compartment_id = var.compartment_ocid
  name           = "logs-${local.project_name}-${local.deploy_id}"
  namespace      = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
}

resource "oci_objectstorage_bucket" "artifacts_bucket" {
  compartment_id = var.compartment_ocid
  name           = "artifacts_${local.project_name}_${local.deploy_id}"
  namespace      = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
}

resource "oci_objectstorage_object" "wallet_object" {
  bucket    = oci_objectstorage_bucket.artifacts_bucket.name
  content   = oci_database_autonomous_database_wallet.adb_wallet.content
  namespace = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  object    = "wallet.zip.b64"
}

resource "oci_objectstorage_preauthrequest" "wallet_par" {
  namespace    = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  bucket       = oci_objectstorage_bucket.artifacts_bucket.name
  name         = "wallet_par"
  access_type  = "ObjectRead"
  object_name = oci_objectstorage_object.wallet_object.object
  time_expires = timeadd(timestamp(), "${var.artifacts_par_expiration_in_days * 24}h")
}

resource "oci_objectstorage_object" "backend_artifact_object" {
  bucket    = oci_objectstorage_bucket.artifacts_bucket.name
  source    = data.archive_file.backend_artifact.output_path
  namespace = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  object    = "backend_artifact.zip"
}

resource "oci_objectstorage_preauthrequest" "backend_artifact_par" {
  namespace    = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  bucket       = oci_objectstorage_bucket.artifacts_bucket.name
  name         = "backend_artifact_par"
  access_type  = "ObjectRead"
  object_name  = oci_objectstorage_object.backend_artifact_object.object
  time_expires = timeadd(timestamp(), "${var.artifacts_par_expiration_in_days * 24}h")
}

resource "oci_objectstorage_object" "ansible_backend_artifact_object" {
  bucket    = oci_objectstorage_bucket.artifacts_bucket.name
  source    = data.archive_file.ansible_backend_artifact.output_path
  namespace = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  object    = "ansible_backend_artifact.zip"
}

resource "oci_objectstorage_preauthrequest" "ansible_backend_artifact_par" {
  namespace    = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  bucket       = oci_objectstorage_bucket.artifacts_bucket.name
  name         = "ansible_backend_artifact_par"
  access_type  = "ObjectRead"
  object_name = oci_objectstorage_object.ansible_backend_artifact_object.object
  time_expires = timeadd(timestamp(), "${var.artifacts_par_expiration_in_days * 24}h")
}

resource "oci_objectstorage_bucket" "artifacts_bucket_standby" {
  provider = oci.peer
  compartment_id = var.compartment_ocid
  name           = "artifacts_${local.project_name}_${local.deploy_id}"
  namespace      = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
}

resource "oci_objectstorage_object" "wallet_object_standby" {
  provider = oci.peer
  bucket    = oci_objectstorage_bucket.artifacts_bucket_standby.name
  content   = oci_database_autonomous_database_wallet.adb_wallet.content
  namespace = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  object    = "wallet.zip.b64"
}

resource "oci_objectstorage_preauthrequest" "wallet_par_standby" {
  provider = oci.peer
  namespace    = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  bucket       = oci_objectstorage_bucket.artifacts_bucket_standby.name
  name         = "wallet_par"
  access_type  = "ObjectRead"
  object_name = oci_objectstorage_object.wallet_object.object
  time_expires = timeadd(timestamp(), "${var.artifacts_par_expiration_in_days * 24}h")
}


resource "oci_objectstorage_object" "backend_artifact_object_standby" {
  provider = oci.peer
  bucket    = oci_objectstorage_bucket.artifacts_bucket_standby.name
  source    = data.archive_file.backend_artifact.output_path
  namespace = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  object    = "backend_artifact.zip"
}

resource "oci_objectstorage_preauthrequest" "backend_artifact_par_standby" {
  provider = oci.peer
  namespace    = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  bucket       = oci_objectstorage_bucket.artifacts_bucket_standby.name
  name         = "backend_artifact_par"
  access_type  = "ObjectRead"
  object_name  = oci_objectstorage_object.backend_artifact_object_standby.object
  time_expires = timeadd(timestamp(), "${var.artifacts_par_expiration_in_days * 24}h")
}

resource "oci_objectstorage_object" "ansible_backend_artifact_object_standby" {
  provider = oci.peer
  bucket    = oci_objectstorage_bucket.artifacts_bucket_standby.name
  source    = data.archive_file.ansible_backend_artifact.output_path
  namespace = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  object    = "ansible_backend_artifact.zip"
}

resource "oci_objectstorage_preauthrequest" "ansible_backend_artifact_par_standby" {
  provider = oci.peer
  namespace    = data.oci_objectstorage_namespace.objectstorage_namespace.namespace
  bucket       = oci_objectstorage_bucket.artifacts_bucket_standby.name
  name         = "ansible_backend_artifact_par"
  access_type  = "ObjectRead"
  object_name = oci_objectstorage_object.ansible_backend_artifact_object_standby.object
  time_expires = timeadd(timestamp(), "${var.artifacts_par_expiration_in_days * 24}h")
}
