locals {
  certificate       = (module.letsencrypt_meta.enabled) ? local.letsencrypt_certificate : local.trusted_ca_certificate
  certificate_chain = (module.letsencrypt_meta.enabled) ? local.letsencrypt_certificate_chain : local.trusted_ca_certificate_chain
  private_key       = (module.letsencrypt_meta.enabled) ? local.letsencrypt_private_key : local.trusted_ca_private_key

  prevent_destroy_secret = !var.create_letsencrypt

  trusted_ca_certificate       = (var.trusted_ca_signed_certificate_filepath != null) ? file(var.trusted_ca_signed_certificate_filepath) : ""
  trusted_ca_certificate_chain = (var.trusted_ca_signed_certificate_chain_filepath != null) ? file(var.trusted_ca_signed_certificate_chain_filepath) : ""
  trusted_ca_private_key       = (var.trusted_ca_signed_certificate_private_key_filepath != null) ? file(var.trusted_ca_signed_certificate_private_key_filepath) : ""

  letsencrypt_certificate       = one(acme_certificate.letsencrypt_acme_certificate[*].certificate_pem)
  letsencrypt_certificate_chain = join("", flatten([acme_certificate.letsencrypt_acme_certificate[*].certificate_pem, acme_certificate.letsencrypt_acme_certificate[*].issuer_pem]))
  letsencrypt_private_key       = one(tls_private_key.letsencrypt_certificate_private_key[*].private_key_pem)
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
