# ------------------------------------------------------------------------------
# SSL Certificate Context
# ------------------------------------------------------------------------------
module "ssl_certificate_import_context" {
  source  = "app.terraform.io/SevenPico/context/null"
  version = "1.1.0"
  context = module.context.self
}

# ------------------------------------------------------------------------------
# SSL Certificate Import
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  source  = "../.."
  context = module.ssl_certificate_import_context.self

  additional_dns_names              = []
  additional_secrets                = { EXAMPLE = "example value" }
  create_mode                       = "From_File"
  create_secret_update_sns          = true
  import_filepath_certificate       = "${path.module}/cert.pem"
  import_filepath_certificate_chain = "${path.module}/chain.pem"
  import_filepath_private_key       = "${path.module}/key.pem"
  import_secret_arn                 = null
  keyname_certificate               = "CERTIFICATE"
  keyname_certificate_chain         = "CERTIFICATE_CHAIN"
  keyname_private_key               = "CERTIFICATE_PRIVATE_KEY"
  kms_key_deletion_window_in_days   = 7
  kms_key_enable_key_rotation       = false
  secret_read_principals            = {}
  secret_update_sns_pub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  zone_id                           = null
}
