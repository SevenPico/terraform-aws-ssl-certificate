#------------------------------------------------------------------------------
# Certificate Meta
#------------------------------------------------------------------------------
module "dns_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"

  enabled             = module.this.enabled
  namespace           = var.common_name
  environment         = null
  stage               = null
  name                = null
  attributes          = []
  delimiter           = "."
  regex_replace_chars = "/[^a-zA-Z0-9-.]/"
  label_order         = ["name", "namespace"]
  tags                = module.this.tags
}

module "letsencrypt_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["letsencrypt"]
  enabled    = var.create_letsencrypt && module.this.enabled
}

module "certificate_secrets_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["secret"]
}

module "certificate_secrets_kms_key_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.certificate_secrets_meta.context
  attributes = ["kms", "key"]
}


#------------------------------------------------------------------------------
# External Let's Encrypt Certificate (as needed)
#------------------------------------------------------------------------------
resource "tls_private_key" "letsencrypt_private_key" {
  count     = module.letsencrypt_meta.enabled ? 1 : 0
  algorithm = "RSA"
}

resource "acme_registration" "acme_registration" {
  count           = module.letsencrypt_meta.enabled ? 1 : 0
  account_key_pem = tls_private_key.letsencrypt_private_key[0].private_key_pem
  email_address   = "nobody@${module.dns_meta.id}"
}

resource "tls_private_key" "letsencrypt_certificate_private_key" {
  count     = module.letsencrypt_meta.enabled ? 1 : 0
  algorithm = "RSA"
}

resource "tls_cert_request" "letsencrypt_certificate_request" {
  count           = module.letsencrypt_meta.enabled ? 1 : 0
  private_key_pem = tls_private_key.letsencrypt_certificate_private_key[0].private_key_pem
  dns_names       = [module.dns_meta.id, "*.${module.dns_meta.id}"]

  subject {
    common_name = "*.${module.dns_meta.id}"
  }
}

resource "acme_certificate" "letsencrypt_acme_certificate" {
  count                   = module.letsencrypt_meta.enabled ? 1 : 0
  account_key_pem         = acme_registration.acme_registration[0].account_key_pem
  certificate_request_pem = tls_cert_request.letsencrypt_certificate_request[0].cert_request_pem

  dns_challenge {
    provider = "route53"
  }
}


#------------------------------------------------------------------------------
# Provide a handle to the Certificate Values regardless of imported or created
#------------------------------------------------------------------------------
locals {
  prevent_destroy_secret = !var.create_letsencrypt

  trusted_ca_certificate       = (var.trusted_ca_signed_certificate_filepath != null) ? file(var.trusted_ca_signed_certificate_filepath) : ""
  trusted_ca_certificate_chain = (var.trusted_ca_signed_certificate_chain_filepath != null) ? file(var.trusted_ca_signed_certificate_chain_filepath) : ""
  trusted_ca_private_key       = (var.trusted_ca_signed_certificate_private_key_filepath != null) ? file(var.trusted_ca_signed_certificate_private_key_filepath) : ""

  letsencrypt_certificate       = one(acme_certificate.letsencrypt_acme_certificate[*].certificate_pem)
  letsencrypt_certificate_chain = join("", flatten([acme_certificate.letsencrypt_acme_certificate[*].certificate_pem, acme_certificate.letsencrypt_acme_certificate[*].issuer_pem]))
  letsencrypt_private_key       = one(tls_private_key.letsencrypt_certificate_private_key[*].private_key_pem)

  certificate       = (module.letsencrypt_meta.enabled) ? local.letsencrypt_certificate : local.trusted_ca_certificate
  certificate_chain = (module.letsencrypt_meta.enabled) ? local.letsencrypt_certificate_chain : local.trusted_ca_certificate_chain
  private_key       = (module.letsencrypt_meta.enabled) ? local.letsencrypt_private_key : local.trusted_ca_private_key
}


#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret - KMS Keys
#--------------------------------------------------------------------------
resource "aws_kms_key" "ssl_certificates_kms_key" {
  count                    = module.this.enabled ? 1 : 0
  description              = "KMS key for ${module.this.id}"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  enable_key_rotation      = false
  tags                     = module.certificate_secrets_kms_key_meta.tags

  policy = length(var.secret_allowed_principals) == 0 ? null : jsonencode({
    Statement = [
      {
        Effect   = "Allow"
        Action   = "kms:*"
        Resource = "*"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
      {
        Effect = "Allow"
        Action = "kms:Decrypt"
        Resource = "*"
        Principal = var.secret_allowed_principals
      }
    ]
  })
}


#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret
#------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "ssl_certificate" {
  count       = (module.certificate_secrets_meta.enabled && !local.prevent_destroy_secret) ? 1 : 0
  name_prefix = "${module.certificate_secrets_meta.id}-"
  tags        = module.certificate_secrets_meta.tags
  kms_key_id  = one(aws_kms_key.ssl_certificates_kms_key[*].key_id)
  description = "SSL Certificate Values"

  policy = length(var.secret_allowed_principals) == 0 ? null : jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = "secretsmanager:GetSecretValue"
      Resource = "*"
      Principal = var.secret_allowed_principals
    }]
  })
}

resource "aws_secretsmanager_secret_version" "ssl_certificate" {
  count     = (module.certificate_secrets_meta.enabled && !local.prevent_destroy_secret) ? 1 : 0
  secret_id = aws_secretsmanager_secret.ssl_certificate[0].id

  secret_string = jsonencode(merge({
    "${var.secretsmanager_certificate_keyname}"             = local.certificate
    "${var.secretsmanager_certificate_chain_keyname}"       = local.certificate_chain
    "${var.secretsmanager_certificate_private_key_keyname}" = local.private_key
  }, var.additional_certificate_secrets))

  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}


#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret (Prevent Destroy)
#------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "ssl_certificate_prevent_destroy" {
  count       = (module.certificate_secrets_meta.enabled && local.prevent_destroy_secret) ? 1 : 0
  name_prefix = "${module.certificate_secrets_meta.id}-"
  tags        = module.certificate_secrets_meta.tags
  kms_key_id  = one(aws_kms_key.ssl_certificates_kms_key[*].key_id)
  description = "SSL Certificate Values"

  # no prevent_destroy for letsencrypt
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "ssl_certificate_prevent_destroy" {
  count     = (module.certificate_secrets_meta.enabled && local.prevent_destroy_secret) ? 1 : 0
  secret_id = aws_secretsmanager_secret.ssl_certificate[0].id
  secret_string = jsonencode(merge({
    "${var.secretsmanager_certificate_keyname}"             = local.certificate
    "${var.secretsmanager_certificate_chain_keyname}"       = local.certificate_chain
    "${var.secretsmanager_certificate_private_key_keyname}" = local.private_key
  }, var.additional_certificate_secrets))

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [secret_string, secret_binary]
  }

}

# ------------------------------------------------------------------------------
# ACM Store
# ------------------------------------------------------------------------------
resource "aws_acm_certificate" "certificate" {
  count             = module.certificate_secrets_meta.enabled ? 1 : 0
  certificate_body  = local.certificate
  certificate_chain = local.certificate_chain
  private_key       = local.private_key
  tags              = module.this.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

# ------------------------------------------------------------------------------
# Duplicate ACM Store for Cloudfront
# ------------------------------------------------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  is_cloudfront_region = data.aws_region.current.name == "us-east-1"
}

resource "aws_acm_certificate" "certificate_cloudfront_region" {
  count             = module.certificate_secrets_meta.enabled && !local.is_cloudfront_region ? 1 : 0
  provider          = aws.cloudfront
  certificate_body  = local.certificate
  certificate_chain = local.certificate_chain
  private_key       = local.private_key
  tags              = module.this.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}
