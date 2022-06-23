provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "source_ssl_certificate" {
  source = "../.."

  enabled = true
  attributes = ["source", "example", "ssl"]

  common_name = "example.com"

  create_letsencrypt                = true
  secret_allowed_accounts           = [ data.aws_caller_identity.current.account_id ]
  secret_update_sns_pub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
  secret_update_sns_sub_principals  = { AWS = [data.aws_caller_identity.current.account_id] }
}


module "import_ssl_certificate" {
  source = "../.."

  enabled = true
  attributes = ["import", "example", "ssl"]

  common_name = "example.com"

  create_letsencrypt = false
  import_from_secret = true
  import_secret_arn  = module.source_ssl_certificate.secret_arn
}
