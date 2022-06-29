# ------------------------------------------------------------------------------
# SSL Certificate Meta
# ------------------------------------------------------------------------------
module "ssl_certificate_source_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
}

module "ssl_certificate_import_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.ssl_certificate_source_meta.context
  attributes = ["import"]
}


# ------------------------------------------------------------------------------
# SSL Certificate Source
# ------------------------------------------------------------------------------
module "ssl_certificate_source" {
  source  = "../.."
  context = module.ssl_certificate_source_meta.context

  additional_secrets                = { EXAMPLE = "example value" }
  create_mode                       = "LetsEncrypt"
  create_secret_update_sns          = true
  common_name                       = var.common_name
  import_filepath_certificate       = null
  import_filepath_certificate_chain = null
  import_filepath_private_key       = null
  import_secret_arn                 = null
  keyname_certificate               = "CERTIFICATE"
  keyname_certificate_chain         = "CERTIFICATE_CHAIN"
  keyname_private_key               = "CERTIFICATE_PRIVATE_KEY"
  secret_allowed_accounts           = [data.aws_caller_identity.current.account_id]
  secret_update_sns_pub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  zone_id                           = null
}


# ------------------------------------------------------------------------------
# SSL Certificate Import
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  source  = "../.."
  context = module.ssl_certificate_source_meta.context

  additional_secrets                = { EXAMPLE = "example value" }
  create_mode                       = "From_Secret"
  create_secret_update_sns          = true
  common_name                       = var.common_name
  import_filepath_certificate       = null
  import_filepath_certificate_chain = null
  import_filepath_private_key       = null
  import_secret_arn                 = module.ssl_certificate_source.secret_arn
  keyname_certificate               = "CERTIFICATE"
  keyname_certificate_chain         = "CERTIFICATE_CHAIN"
  keyname_private_key               = "CERTIFICATE_PRIVATE_KEY"
  secret_allowed_accounts           = [data.aws_caller_identity.current.account_id]
  secret_update_sns_pub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  zone_id                           = null
}
