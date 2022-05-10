locals {
  
  # create_letsencrypt = var.create_letsencrypt
  # import_from_file
  # import_from_secret


  letsencrypt_certificate       = one(acme_certificate.letsencrypt_acme_certificate[*].certificate_pem)
  letsencrypt_private_key       = one(tls_private_key.letsencrypt_certificate_private_key[*].private_key_pem)
  letsencrypt_certificate_chain = join("", [
    acme_certificate.letsencrypt_acme_certificate[*].certificate_pem,
    acme_certificate.letsencrypt_acme_certificate[*].issuer_pem
  ])

  imported_file_certificate       = var.import_from_file ? file(var.import_certificate_filepath) : ""
  imported_file_private_key       = var.import_from_file ? file(var.import_private_key_filepath) : ""
  imported_file_certificate_chain = var.import_from_file ? file(var.import_certificate_chain_filepath) : ""

  imported_secret_certificate       = jsondecode(data.aws_secretsmanager_secret_version.imported.secret_string)[var.certificate_key_name]
  imported_secret_certificate_chain = jsondecode(data.aws_secretsmanager_secret_version.imported.secret_string)[var.private_key_name]
  imported_secret_private_key       = jsondecode(data.aws_secretsmanager_secret_version.imported.secret_string)[var.certificate_chain_key_name]

  certificate       = var.create_letsencrypt ? local.letsencrypt_certificate : (
                      var.import_from_file   ? local.imported_file_private_key :
                      var.import_from_secret ? local.imported_secret_certificate_chain : "")

  private_key       = var.create_letsencrypt ? local.letsencrypt_certificate : (
                      var.import_from_file   ? local.imported_file_private_key :
                      var.import_from_secret ? local.imported_secret_certificate_chain : "")

  certificate_chain = var.create_letsencrypt ? local.letsencrypt_certificate : (
                      var.import_from_file   ? local.imported_file_private_key :
                      var.import_from_secret ? local.imported_secret_certificate_chain : "")
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "imported" {
  count = (module.this.enabled && var.import_from_secret) ? 1 : 0

  secret_id     = var.import_secret_arn
  version_stage = "AWSCURRENT"
}
