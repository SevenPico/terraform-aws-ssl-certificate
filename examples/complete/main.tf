
module "ssl_certificate" {
  source  = "../.."
  context = module.this.context

  common_name                    = var.common_name
  create_letsencrypt             = var.create_letsencrypt
  additional_certificate_secrets = var.additional_certificate_secrets

  secretsmanager_certificate_keyname             = var.secretsmanager_certificate_keyname
  secretsmanager_certificate_chain_keyname       = var.secretsmanager_certificate_chain_keyname
  secretsmanager_certificate_private_key_keyname = var.secretsmanager_certificate_private_key_keyname

  trusted_ca_signed_certificate_filepath             = var.trusted_ca_signed_certificate_filepath
  trusted_ca_signed_certificate_chain_filepath       = var.trusted_ca_signed_certificate_chain_filepath
  trusted_ca_signed_certificate_private_key_filepath = var.trusted_ca_signed_certificate_private_key_filepath
}
