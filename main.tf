locals {
  use_letsencrypt     = var.create_letsencrypt
  use_imported_file   = var.import_from_file
  use_imported_secret = var.import_from_secret

  letsencrypt_certificate       = one(acme_certificate.letsencrypt_acme_certificate[*].certificate_pem)
  letsencrypt_private_key       = one(tls_private_key.letsencrypt_certificate_private_key[*].private_key_pem)
  letsencrypt_certificate_chain = join("", [
    acme_certificate.letsencrypt_acme_certificate[*].certificate_pem,
    acme_certificate.letsencrypt_acme_certificate[*].issuer_pem
  ])

  imported_file_certificate       = var.import_from_file ? file(var.import_certificate_filepath) : ""
  imported_file_private_key       = var.import_from_file ? file(var.import_private_key_filepath) : ""
  imported_file_certificate_chain = var.import_from_file ? file(var.import_certificate_chain_filepath) : ""

  imported_secret_certificate       = jsondecode(data.aws_secretsmanager_secret_version.imported.secret_string)["CERTIFICATE"]
  imported_secret_certificate_chain = jsondecode(data.aws_secretsmanager_secret_version.imported.secret_string)["CERTIFICATE_CHAIN"]
  imported_secret_private_key       = jsondecode(data.aws_secretsmanager_secret_version.imported.secret_string)["CERTIFICATE_PRIVATE_KEY"]

  certificate       = local.use_letsencrypt ? local.letsencrypt_certificate : (
                      local.use_imported    ? local.imported_certificate :
                      local.use_secret      ? local.secret_certificate : "")

  private_key       = local.use_letsencrypt ? local.letsencrypt_certificate : (
                      local.use_imported    ? local.imported_certificate :
                      local.use_secret      ? local.secret_certificate : "")

  certificate_chain = local.use_letsencrypt ? local.letsencrypt_certificate : (
                      local.use_imported    ? local.imported_certificate :
                      local.use_secret      ? local.secret_certificate : "")
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "imported" {
  count = module.this.enabled && var.import_from_secret ? 1 : 0

  secret_id     = var.import_secret_arn
  version_stage = "AWSCURRENT"
}
