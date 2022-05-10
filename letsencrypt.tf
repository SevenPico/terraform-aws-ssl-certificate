module "letsencrypt_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  enabled    = module.this.enabled && var.create_letsencrypt
  attributes = ["letsencrypt"]
}

resource "tls_private_key" "letsencrypt_private_key" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  algorithm = "RSA"
}

resource "acme_registration" "acme_registration" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  account_key_pem = tls_private_key.letsencrypt_private_key[0].private_key_pem
  email_address   = "nobody@${var.common_name}"
}

resource "tls_private_key" "letsencrypt_certificate_private_key" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  algorithm = "RSA"
}

resource "tls_cert_request" "letsencrypt_certificate_request" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  private_key_pem = tls_private_key.letsencrypt_certificate_private_key[0].private_key_pem
  dns_names       = [var.common_name, "*.${var.common_name}"]

  subject {
    common_name = "*.${var.common_name}"
  }
}

resource "acme_certificate" "letsencrypt_acme_certificate" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  account_key_pem         = acme_registration.acme_registration[0].account_key_pem
  certificate_request_pem = tls_cert_request.letsencrypt_certificate_request[0].cert_request_pem

  dns_challenge {
    provider = "route53"
  }
}
