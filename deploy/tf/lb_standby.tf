resource "oci_core_public_ip" "reserved_ip_standby" {
  provider = oci.peer
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"

  lifecycle {
    ignore_changes = [private_ip_id]
  }
}

resource "oci_load_balancer" "lb_standby" {
  provider = oci.peer
  shape          = "flexible"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.publicsubnet_standby.id
  ]

  shape_details {
    maximum_bandwidth_in_mbps = var.lb_shape_max_bandwidth
    minimum_bandwidth_in_mbps = var.lb_shape_min_bandwidth
  }

  display_name = "${local.project_name} ${local.deploy_id}"
  reserved_ips {
    id = oci_core_public_ip.reserved_ip_standby.id
  }
}

resource "oci_load_balancer_backend_set" "backend_backendset_standby" {
  provider = oci.peer
  name             = "backend_backendset"
  load_balancer_id = oci_load_balancer.lb_standby.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "8080"
    protocol            = "TCP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_backend" "backend_backend_standby" {
  provider = oci.peer
  for_each = local.list_app_stdby_instances
  backendset_name  = oci_load_balancer_backend_set.backend_backendset_standby.name
  ip_address       = oci_core_instance.app_stdby[each.key].private_ip
  load_balancer_id = oci_load_balancer.lb_standby.id
  port             = 8080
}

resource "oci_load_balancer_load_balancer_routing_policy" "routing_policy_standby" {
  provider = oci.peer
  condition_language_version = "V1"
  load_balancer_id           = oci_load_balancer.lb_standby.id
  name                       = "routing_policy"

  rules {
    name      = "routing_to_backend"
    condition = "any(http.request.url.path sw (i '/api'))"
    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = oci_load_balancer_backend_set.backend_backendset_standby.name
    }
  }
}

resource "oci_load_balancer_rule_set" "rule_set_to_ssl_standby" {
  provider = oci.peer
  name             = "rule_set_to_ssl"
  load_balancer_id = oci_load_balancer.lb_standby.id
  items {
    description = "Redirection to SSL"
    action      = "REDIRECT"

    conditions {
      attribute_name  = "PATH"
      attribute_value = "/"

      operator = "FORCE_LONGEST_PREFIX_MATCH"
    }

    redirect_uri {
      port     = 443
      protocol = "HTTPS"
    }
    response_code = 302
  }
}

resource "oci_load_balancer_listener" "listener_ssl_standby" {
  provider = oci.peer
  load_balancer_id         = oci_load_balancer.lb_standby.id
  name                     = "https"
  routing_policy_name      = oci_load_balancer_load_balancer_routing_policy.routing_policy_standby.name
  default_backend_set_name = oci_load_balancer_backend_set.backend_backendset_standby.name
  port                     = 443
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.certificate_standby.certificate_name
    verify_peer_certificate = false
    protocols               = ["TLSv1.1", "TLSv1.2"]
    server_order_preference = "ENABLED"
    cipher_suite_name       = oci_load_balancer_ssl_cipher_suite.ssl_cipher_suite_standby.name
  }
}

resource "oci_load_balancer_listener" "listener_nossl_standby" {
  provider = oci.peer
  load_balancer_id         = oci_load_balancer.lb_standby.id
  name                     = "http"
  routing_policy_name      = oci_load_balancer_load_balancer_routing_policy.routing_policy_standby.name
  default_backend_set_name = oci_load_balancer_backend_set.backend_backendset_standby.name
  rule_set_names           = [oci_load_balancer_rule_set.rule_set_to_ssl_standby.name]
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }

}

resource "oci_load_balancer_certificate" "certificate_standby" {
  provider = oci.peer
  certificate_name = "${local.project_name}.victormartin.dev"
  load_balancer_id = oci_load_balancer.lb_standby.id

  ca_certificate     = file(var.cert_fullchain)
  private_key        = file(var.cert_private_key)
  public_certificate = file(var.cert_fullchain)

}

resource "oci_load_balancer_ssl_cipher_suite" "ssl_cipher_suite_standby" {
  provider = oci.peer
  name             = "ssl_cipher_suite"
  ciphers          = ["AES128-SHA", "AES256-SHA"]
  load_balancer_id = oci_load_balancer.lb_standby.id
}