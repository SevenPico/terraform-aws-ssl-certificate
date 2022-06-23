# ------------------------------------------------------------------------------
# SSL Certificate Meta
# ------------------------------------------------------------------------------
module "ssl_certificate_source_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
}

module "ssl_certificate_import_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.ssl_certificate_source_meta.context
  attributes = ["import"]
}


  # ------------------------------------------------------------------------------
# SSL Certificate Source
# ------------------------------------------------------------------------------
module "ssl_certificate_source" {
  source = "../.."
  context = module.ssl_certificate_source_meta.context

  create_letsencrypt                = true
  secret_allowed_accounts           = [ data.aws_caller_identity.current.account_id ]
  secret_update_sns_pub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
}


# ------------------------------------------------------------------------------
# SSL Certificate Import
# ------------------------------------------------------------------------------
module "ssl_certificate_import" {
  source = "../.."
  context = module.ssl_certificate_source_meta.context

  create_letsencrypt = false
  import_from_secret = true
  import_secret_arn  = module.ssl_certificate_source.secret_arn
}
