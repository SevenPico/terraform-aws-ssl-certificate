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
  ignore_secret_changes             = false
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

data "aws_secretsmanager_secret" "source" {
  count = module.this.enabled ? 1 : 0
  depends_on = [module.ssl_certificate_source]

  arn = module.ssl_certificate_source.secret_arn
}
data "aws_secretsmanager_secret_version" "source" {
  count = module.this.enabled ? 1 : 0
  depends_on = [module.ssl_certificate_source]

  secret_id = data.aws_secretsmanager_secret.source[0].id
  version_stage = "AWSCURRENT"
}

resource "local_file" "key" {
  count = module.this.enabled ? 1 : 0
  filename = "${path.module}/key.pem"
  content  = jsondecode(data.aws_secretsmanager_secret_version.source[0].secret_string)[module.ssl_certificate_source.keyname_private_key]
}

resource "local_file" "certificate" {
  count = module.this.enabled ? 1 : 0
  filename = "${path.module}/cert.pem"
  content  = jsondecode(data.aws_secretsmanager_secret_version.source[0].secret_string)[module.ssl_certificate_source.keyname_certificate]
}

resource "local_file" "certificate_chain" {
  count = module.this.enabled ? 1 : 0
  filename = "${path.module}/chain.pem"
  content  = jsondecode(data.aws_secretsmanager_secret_version.source[0].secret_string)[module.ssl_certificate_source.keyname_certificate_chain]
}


# ------------------------------------------------------------------------------
# SSL Certificate Import
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  source  = "../.."
  context = module.ssl_certificate_import_meta.context
  depends_on = [module.ssl_certificate_source ,local_file.certificate, local_file.certificate_chain, local_file.key]

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
