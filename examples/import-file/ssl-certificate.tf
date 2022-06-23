provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "source_ssl_certificate" {
  source = "../.."

  enabled    = true
  attributes = ["source", "example", "ssl"]

  common_name = "example.com"

  create_letsencrypt               = true
  secret_allowed_accounts          = [data.aws_caller_identity.current.account_id]
  secret_update_sns_pub_principals = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals = { AWS = [data.aws_caller_identity.current.account_id] }
}

resource "local_sensitive_file" "key" {
  filename = "${path.module}/key.pem"
  content  = module.source_ssl_certificate.private_key
}

resource "local_file" "certificate" {
  filename = "${path.module}/cert.pem"
  content  = module.source_ssl_certificate.certificate
}

resource "local_file" "certificate_chain" {
  filename = "${path.module}/chain.pem"
  content  = module.source_ssl_certificate.certificate_chain
}

module "import_ssl_certificate" {
  source = "../.."

  enabled    = true
  attributes = ["import", "example", "ssl"]

  common_name = "example.com"

  create_letsencrypt = false
  import_from_file   = true
  import_secret_arn  = module.source_ssl_certificate.secret_arn

  import_certificate_filepath       = "${path.module}/cert.pem"
  import_certificate_chain_filepath = "${path.module}/chain.pem"
  import_private_key_filepath       = "${path.module}/key.pem"

  secret_allowed_accounts          = [data.aws_caller_identity.current.account_id]
}
