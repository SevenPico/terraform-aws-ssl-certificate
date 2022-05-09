variable "create_letsencrypt" {
  default     = true
  type        = bool
  description = "If this is set to true, Let's Encrypt certificate values will be created."
}

variable "common_name" {
  type        = string
  description = "The domain name that the certificate will be created for.  Currently this value will be wild-carded."
}

variable "trusted_ca_signed_certificate_filepath" {
  default = null
}

variable "trusted_ca_signed_certificate_chain_filepath" {
  default = null
}

variable "trusted_ca_signed_certificate_private_key_filepath" {
  default = null
}

variable "secretsmanager_certificate_keyname" {
  default = "CERTIFICATE"
}

variable "secretsmanager_certificate_chain_keyname" {
  default = "CERTIFICATE_CHAIN"
}

variable "secretsmanager_certificate_private_key_keyname" {
  default = "CERTIFICATE_PRIVATE_KEY"
}

variable "additional_certificate_secrets" {
  default = {}
}

variable "secret_allowed_accounts" {
  type = list(number)
}

variable "create_sns_topic" {
  type = bool
  default = false
}

variable "sns_pub_principals" {
  type = map
  default = {}
}

variable "sns_sub_principals" {
  type = map
  default = {}
}
