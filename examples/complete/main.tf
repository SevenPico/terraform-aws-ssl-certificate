
module "ssl_certificate" {
  source = "../.."
  context            = module.this.context
  ssl_certificate_common_name        = var.ssl_certificate_common_name
  ssl_certificate_create_self_signed = var.ssl_certificate_create_self_signed
  ssl_certificate_additional_certificate_secrets = var.ssl_certificate_additional_certificate_secrets

  ssl_certificate_secretsmanager_certificate_keyname = var.ssl_certificate_secretsmanager_certificate_keyname
  ssl_certificate_secretsmanager_certificate_chain_keyname = var.ssl_certificate_secretsmanager_certificate_chain_keyname
  ssl_certificate_secretsmanager_certificate_private_key_keyname = var.ssl_certificate_secretsmanager_certificate_private_key_keyname

  ssl_certificate_trusted_ca_signed_certificate_filepath = var.ssl_certificate_trusted_ca_signed_certificate_filepath
  ssl_certificate_trusted_ca_signed_certificate_chain_filepath = var.ssl_certificate_trusted_ca_signed_certificate_chain_filepath
  ssl_certificate_trusted_ca_signed_certificate_private_key_filepath = var.ssl_certificate_trusted_ca_signed_certificate_private_key_filepath
}
