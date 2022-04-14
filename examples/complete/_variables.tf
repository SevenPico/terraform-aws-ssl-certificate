
variable "ssl_certificate_create_letsencrypt" {}
variable "ssl_certificate_common_name" {}

variable "ssl_certificate_trusted_ca_signed_certificate_filepath" { default = null }
variable "ssl_certificate_trusted_ca_signed_certificate_chain_filepath" { default = null }
variable "ssl_certificate_trusted_ca_signed_certificate_private_key_filepath" { default = null }

variable "ssl_certificate_secretsmanager_certificate_keyname" { default = "CERTIFICATE" }
variable "ssl_certificate_secretsmanager_certificate_chain_keyname" { default = "CERTIFICATE_CHAIN" }
variable "ssl_certificate_secretsmanager_certificate_private_key_keyname" { default = "CERTIFICATE_PRIVATE_KEY" }


variable "ssl_certificate_additional_certificate_secrets" {default = {}}
