# ------------------------------------------------------------------------------
# SSL Certificate Meta
# ------------------------------------------------------------------------------
module "ssl_certificate_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
}


# ------------------------------------------------------------------------------
# SSL Certificate
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  source = "../.."
  context = module.ssl_certificate_meta.context

  additional_secrets = {
    EXAMPLE = "example value"
  }

  create_letsencrypt                = true
  create_secret_update_sns          = true
  ignore_secret_changes             = true
  import_from_file                  = false
  import_from_secret                = false
  import_private_key_filepath       = null
  import_certificate_chain_filepath = null
  import_certificate_filepath       = null
  import_secret_arn                 = null
  secret_allowed_accounts           = [ data.aws_caller_identity.current.account_id ]
  secret_update_sns_pub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
}
