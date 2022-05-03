
variable "create_letsencrypt" {}
variable "common_name" {}

variable "trusted_ca_signed_certificate_filepath" { default = null }
variable "trusted_ca_signed_certificate_chain_filepath" { default = null }
variable "trusted_ca_signed_certificate_private_key_filepath" { default = null }

variable "secretsmanager_certificate_keyname" { default = "CERTIFICATE" }
variable "secretsmanager_certificate_chain_keyname" { default = "CERTIFICATE_CHAIN" }
variable "secretsmanager_certificate_private_key_keyname" { default = "CERTIFICATE_PRIVATE_KEY" }


variable "additional_certificate_secrets" {default = {}}
