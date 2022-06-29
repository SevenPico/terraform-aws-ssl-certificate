# ------------------------------------------------------------------------------
# SSL Certificate Meta
# ------------------------------------------------------------------------------
module "ssl_certificate_import_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
}

# ------------------------------------------------------------------------------
# SSL Certificate Import
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  source  = "../.."
  context = module.ssl_certificate_import_meta.context

  additional_secrets                = { EXAMPLE = "example value" }
  create_mode                       = "From_File"
  create_secret_update_sns          = true
  common_name                       = var.common_name
  ignore_secret_changes             = true
  import_filepath_certificate       = "${path.module}/cert.pem"
  import_filepath_certificate_chain = "${path.module}/chain.pem"
  import_filepath_private_key       = "${path.module}/key.pem"
  import_secret_arn                 = null
  keyname_certificate               = "CERTIFICATE"
  keyname_certificate_chain         = "CERTIFICATE_CHAIN"
  keyname_private_key               = "CERTIFICATE_PRIVATE_KEY"
  secret_allowed_accounts           = [data.aws_caller_identity.current.account_id]
  secret_update_sns_pub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  zone_id                           = null
}
