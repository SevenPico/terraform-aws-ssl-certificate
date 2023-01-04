locals {
  secret_arn = local.create_secret ? module.ssl_secret.arn : (
               local.create_from_secret ? var.import_secret_arn : "")

  secrets_manager_document = local.secret_arn != "" ? jsondecode(one(data.aws_secretsmanager_secret_version.this[*].secret_string)) : {}
}


data "aws_secretsmanager_secret_version" "this" {
  count = module.context.enabled && !local.create_acm_only ? 1 : 0
  depends_on = [module.ssl_secret]

  secret_id     = local.secret_arn
  version_stage = "AWSCURRENT"
}


# ------------------------------------------------------------------------------
# ACM (Lets Encrypt, Imported from file or secret)
# ------------------------------------------------------------------------------
resource "aws_acm_certificate" "imported" {
  count = module.context.enabled && !local.create_acm_only ? 1 : 0
  depends_on = [module.ssl_secret]

  certificate_body  = lookup(local.secrets_manager_document, var.keyname_certificate, "")
  certificate_chain = lookup(local.secrets_manager_document, var.keyname_certificate_chain, "")
  private_key       = lookup(local.secrets_manager_document, var.keyname_private_key, "")
  tags              = module.context.tags

  lifecycle {
    create_before_destroy = true
  }
}


# ------------------------------------------------------------------------------
# ACM (AWS Managed)
# ------------------------------------------------------------------------------
module "acm_only" {
  source  = "registry.terraform.io/cloudposse/acm-request-certificate/aws"
  version = "0.16.0"
  context = module.context.context
  enabled = module.context.enabled && local.create_acm_only

  domain_name                                 = var.create_wildcard ? "*.${module.context.domain_name}" : module.context.domain_name
  process_domain_validation_options           = true
  ttl                                         = "300"
  certificate_authority_arn                   = null
  certificate_transparency_logging_preference = true
  subject_alternative_names                   = var.create_wildcard ? [] : var.additional_dns_names
  wait_for_certificate_issued                 = false
  validation_method                           = "DNS"
  zone_id                                     = var.zone_id
  zone_name                                   = ""
}
