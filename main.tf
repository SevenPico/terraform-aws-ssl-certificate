data "aws_region" "current" {}

locals {
  is_cloudfront_region = data.aws_region.current.name == "us-east-1"
}

#------------------------------------------------------------------------------
# Certificate Meta
#------------------------------------------------------------------------------
module "dns_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"

  enabled             = module.this.enabled
  namespace           = var.ssl_certificate_common_name
  environment         = null
  stage               = null
  name                = null
  attributes          = []
  delimiter           = "."
  regex_replace_chars = "/[^a-zA-Z0-9-.]/"
  label_order         = ["name", "namespace"]
  tags                = module.this.tags
}

module "self_signed_certificate_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["self-signed"]
  enabled    = var.ssl_certificate_create_self_signed && module.this.enabled
}

module "certificate_secrets_kms_key_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = var.ssl_certificate_create_self_signed ? module.self_signed_certificate_secrets_meta.context : module.trusted_ca_certificate_secrets_meta.context
  attributes = ["kms", "key"]
}


module "self_signed_certificate_secrets_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.self_signed_certificate_meta.context
  attributes = ["secret"]
}

module "trusted_ca_certificate_secrets_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["secret"]
  enabled    = !var.ssl_certificate_create_self_signed && module.this.enabled
}


#------------------------------------------------------------------------------
# External Self Signed Certificate (as needed)
#------------------------------------------------------------------------------
resource "tls_private_key" "self_signed_private_key" {
  count     = module.self_signed_certificate_meta.enabled ? 1 : 0
  algorithm = "RSA"
}

resource "acme_registration" "acme_registration" {
  count           = module.self_signed_certificate_meta.enabled ? 1 : 0
  account_key_pem = tls_private_key.self_signed_private_key[0].private_key_pem
  email_address   = "nobody@${module.dns_meta.id}"
}

resource "tls_private_key" "self_signed_certificate_private_key" {
  count     = module.self_signed_certificate_meta.enabled ? 1 : 0
  algorithm = "RSA"
}

resource "tls_cert_request" "self_signed_certificate_request" {
  count           = module.self_signed_certificate_meta.enabled ? 1 : 0
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.self_signed_certificate_private_key[0].private_key_pem
  dns_names       = [module.dns_meta.id, "*.${module.dns_meta.id}"]
  #  lifecycle {
  #    ignore_changes = [subject]
  #  }
  subject {
    common_name = "*.${module.dns_meta.id}"
  }
}

resource "acme_certificate" "self_signed_acme_certificate" {
  count                   = module.self_signed_certificate_meta.enabled ? 1 : 0
  account_key_pem         = acme_registration.acme_registration[0].account_key_pem
  certificate_request_pem = tls_cert_request.self_signed_certificate_request[0].cert_request_pem
  #  lifecycle {
  #    ignore_changes = [dns_challenge]
  #  }
  dns_challenge {
    provider = "route53"
  }

}


#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret - KMS Keys
#------------------------------------------------------------------------------
module "ssl_certificates_kms_key" {
  source  = "registry.terraform.io/cloudposse/kms-key/aws"
  version = "0.12.1"
  context = module.certificate_secrets_kms_key_meta.context

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  description              = "KMS key for ${module.this.id}"
  enable_key_rotation      = false
  key_usage                = "ENCRYPT_DECRYPT"
}

#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret - Self Signed Certificate
#------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "self_signed_ssl_certificate" {
  count       = module.self_signed_certificate_secrets_meta.enabled ? 1 : 0
  depends_on  = [acme_certificate.self_signed_acme_certificate]
  name_prefix = "${module.self_signed_certificate_secrets_meta.id}-"
  tags        = module.self_signed_certificate_secrets_meta.tags
  kms_key_id  = module.ssl_certificates_kms_key.key_id
  description = "SSL Certificate Values"
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "self_signed_ssl_certificate" {
  count      = module.self_signed_certificate_secrets_meta.enabled ? 1 : 0
  depends_on = [aws_secretsmanager_secret.self_signed_ssl_certificate]
  secret_id  = aws_secretsmanager_secret.self_signed_ssl_certificate[0].id

  lifecycle {
    ignore_changes = [secret_binary, secret_string]
    prevent_destroy = false
  }
  secret_string = jsonencode(merge({
    CERTIFICATE             = acme_certificate.self_signed_acme_certificate[0].certificate_pem
    CERTIFICATE_CHAIN       = "${acme_certificate.self_signed_acme_certificate[0].certificate_pem}${acme_certificate.self_signed_acme_certificate[0].issuer_pem}"
    CERTIFICATE_PRIVATE_KEY = tls_private_key.self_signed_certificate_private_key[0].private_key_pem
  }, var.ssl_certificate_additional_certificate_secrets))
}


#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret - Trusted CA Signed Certificate
#------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "trusted_ca_ssl_certificate" {
  count       = module.trusted_ca_certificate_secrets_meta.enabled ? 1 : 0
  name_prefix = "${module.trusted_ca_certificate_secrets_meta.id}-"
  tags        = module.trusted_ca_certificate_secrets_meta.tags
  kms_key_id  = module.ssl_certificates_kms_key.key_id
  description = "SSL Certificate Values"
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "trusted_ca_ssl_certificate" {
  count      = module.trusted_ca_certificate_secrets_meta.enabled ? 1 : 0
  depends_on = [aws_secretsmanager_secret.trusted_ca_ssl_certificate]
  secret_id  = aws_secretsmanager_secret.trusted_ca_ssl_certificate[0].id
  lifecycle {
    ignore_changes  = [secret_string, secret_binary]
    prevent_destroy = false
  }
  secret_string = jsonencode(merge({
    "${var.ssl_certificate_secretsmanager_certificate_keyname}"             = var.ssl_certificate_trusted_ca_signed_certificate_filepath != null ? file(var.ssl_certificate_trusted_ca_signed_certificate_filepath) : ""
    "${var.ssl_certificate_secretsmanager_certificate_chain_keyname}"       = var.ssl_certificate_trusted_ca_signed_certificate_chain_filepath != null ? file(var.ssl_certificate_trusted_ca_signed_certificate_chain_filepath) : ""
    "${var.ssl_certificate_secretsmanager_certificate_private_key_keyname}" = var.ssl_certificate_trusted_ca_signed_certificate_private_key_filepath != null ? file(var.ssl_certificate_trusted_ca_signed_certificate_private_key_filepath) : ""
  }, var.ssl_certificate_additional_certificate_secrets))
}


#------------------------------------------------------------------------------
# ACM - Lookup Certificate Secrets
#------------------------------------------------------------------------------
data "aws_secretsmanager_secret" "ssl_certificate_values" {
  count = module.this.enabled ? 1 : 0
  depends_on = [
    aws_secretsmanager_secret.self_signed_ssl_certificate[0],
    aws_secretsmanager_secret_version.self_signed_ssl_certificate[0],
    aws_secretsmanager_secret.trusted_ca_ssl_certificate[0],
    aws_secretsmanager_secret_version.trusted_ca_ssl_certificate[0],
  ]
  arn = var.ssl_certificate_create_self_signed ? aws_secretsmanager_secret.self_signed_ssl_certificate[0].arn : aws_secretsmanager_secret.trusted_ca_ssl_certificate[0].arn

}

data "aws_secretsmanager_secret_version" "ssl_certificate_values" {
  count         = module.this.enabled ? 1 : 0
  depends_on    = [aws_secretsmanager_secret_version.self_signed_ssl_certificate, aws_secretsmanager_secret_version.trusted_ca_ssl_certificate]
  secret_id     = data.aws_secretsmanager_secret.ssl_certificate_values[0].id
  version_stage = "AWSCURRENT"
}


#------------------------------------------------------------------------------
# Provide a handle to the Certificate Values regardless of imported or created
#------------------------------------------------------------------------------
locals {
  ssl_private_key       = module.this.enabled ? jsondecode(data.aws_secretsmanager_secret_version.ssl_certificate_values[0].secret_string)[var.ssl_certificate_secretsmanager_certificate_private_key_keyname] : null
  ssl_certificate       = module.this.enabled ? jsondecode(data.aws_secretsmanager_secret_version.ssl_certificate_values[0].secret_string)[var.ssl_certificate_secretsmanager_certificate_keyname] : null
  ssl_certificate_chain = module.this.enabled ? jsondecode(data.aws_secretsmanager_secret_version.ssl_certificate_values[0].secret_string)[var.ssl_certificate_secretsmanager_certificate_chain_keyname] : null
}


#------------------------------------------------------------------------------
# ACM Store
#------------------------------------------------------------------------------
resource "aws_acm_certificate" "self_signed_certificate" {
  count             = module.self_signed_certificate_meta.enabled ? 1 : 0
  certificate_body  = local.ssl_certificate
  certificate_chain = local.ssl_certificate_chain
  private_key       = local.ssl_private_key
  tags              = module.this.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

resource "aws_acm_certificate" "self_signed_certificate_cloudfront_region" {
  count             = module.self_signed_certificate_meta.enabled && !local.is_cloudfront_region ? 1 : 0
  provider          = aws.cloudfront
  certificate_body  = local.ssl_certificate
  certificate_chain = local.ssl_certificate_chain
  private_key       = local.ssl_private_key
  tags              = module.this.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

resource "aws_acm_certificate" "trusted_ca_certificate" {
  count             = module.trusted_ca_certificate_secrets_meta.enabled ? 1 : 0
  certificate_body  = local.ssl_certificate
  certificate_chain = local.ssl_certificate_chain
  private_key       = local.ssl_private_key
  tags              = module.this.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

resource "aws_acm_certificate" "trusted_ca_certificate_cloudfront_region" {
  count             = module.trusted_ca_certificate_secrets_meta.enabled && !local.is_cloudfront_region ? 1 : 0
  provider          = aws.cloudfront
  certificate_body  = local.ssl_certificate
  certificate_chain = local.ssl_certificate_chain
  private_key       = local.ssl_private_key
  tags              = module.this.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}
