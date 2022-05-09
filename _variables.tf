variable "create_letsencrypt" {
  default     = true
  type        = bool
  description = "If this is set to true, Let's Encrypt certificate values will be created."
}

variable "common_name" {
  type        = string
  description = "The domain name that the certificate will be created for.  Currently this value will be wild-carded."
}


variable "certificate_keyname" {
  default = "CERTIFICATE"
}

variable "certificate_chain_keyname" {
  default = "CERTIFICATE_CHAIN"
}

variable "certificate_private_key_keyname" {
  default = "CERTIFICATE_PRIVATE_KEY"
}

variable "additional_secrets" {
  default = {}
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




variable "secret_allowed_accounts" {
  type = list(number)
}


variable "create_secret_update_sns_topic" {
  type = bool
  default = false
}

variable "secret_update_sns_pub_principals" {
  type = map
  default = {}
}

variable "secret_update_sns_sub_principals" {
  type = map
  default = {}
}
