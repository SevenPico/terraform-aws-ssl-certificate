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

  create_letsencrypt               = true
  secret_allowed_accounts          = [data.aws_caller_identity.current.account_id]
  secret_update_sns_pub_principals = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals = { AWS = [data.aws_caller_identity.current.account_id] }
}

resource "local_sensitive_file" "key" {
  filename = "${path.module}/key.pem"
  content  = module.ssl_certificate_source.private_key
}

resource "local_file" "certificate" {
  filename = "${path.module}/cert.pem"
  content  = module.ssl_certificate_source.certificate
}

resource "local_file" "certificate_chain" {
  filename = "${path.module}/chain.pem"
  content  = module.ssl_certificate_source.certificate_chain
}


# ------------------------------------------------------------------------------
# SSL Certificate Import
# ------------------------------------------------------------------------------
module "ssl_certificate_import" {
  source = "../.."
  context = module.ssl_certificate_import_meta.context

  create_letsencrypt = false
  import_from_file   = true
  import_secret_arn  = module.ssl_certificate_source.secret_arn

  import_certificate_filepath       = "${path.module}/cert.pem"
  import_certificate_chain_filepath = "${path.module}/chain.pem"
  import_private_key_filepath       = "${path.module}/key.pem"

  secret_allowed_accounts          = [data.aws_caller_identity.current.account_id]
}
