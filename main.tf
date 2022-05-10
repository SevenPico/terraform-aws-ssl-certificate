locals {
  create_secret = var.create_letsencrypt || var.import_from_file

  letsencrypt_certificate = one(acme_certificate.this[*].certificate_pem)
  letsencrypt_private_key = one(tls_private_key.certificate_key[*].private_key_pem)
  letsencrypt_certificate_chain = join("", flatten([
    acme_certificate.this[*].certificate_pem,
    acme_certificate.this[*].issuer_pem
  ]))

  imported_file_certificate       = var.import_from_file ? file(var.import_certificate_filepath) : ""
  imported_file_private_key       = var.import_from_file ? file(var.import_private_key_filepath) : ""
  imported_file_certificate_chain = var.import_from_file ? file(var.import_certificate_chain_filepath) : ""

  imported_secret = var.import_from_secret ? jsondecode(one(data.aws_secretsmanager_secret_version.imported[*].secret_string)) : {}

  imported_secret_certificate       = lookup(local.imported_secret, var.certificate_keyname, "")
  imported_secret_private_key       = lookup(local.imported_secret, var.private_key_keyname, "")
  imported_secret_certificate_chain = lookup(local.imported_secret, var.certificate_chain_keyname, "")

  certificate = var.create_letsencrypt ? local.letsencrypt_certificate : (
                var.import_from_file   ? local.imported_file_certificate :
                var.import_from_secret ? local.imported_secret_certificate : "")

  private_key = var.create_letsencrypt ? local.letsencrypt_private_key : (
                var.import_from_file   ? local.imported_file_private_key :
                var.import_from_secret ? local.imported_secret_private_key : "")

  certificate_chain = var.create_letsencrypt ? local.letsencrypt_certificate_chain : (
                      var.import_from_file   ? local.imported_file_certificate_chain :
                      var.import_from_secret ? local.imported_secret_certificate_chain : "")
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "imported" {
  count = (module.this.enabled && var.import_from_secret) ? 1 : 0

  secret_id     = var.import_secret_arn
  version_stage = "AWSCURRENT"
}
