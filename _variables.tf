variable "create_letsencrypt" {
  description = "If this is set to true, Let's Encrypt certificate values will be created."
  type        = bool
  default     = true
}

variable "import_from_file" {
  description = "If this is set to true, certificate is imported from provided filepaths."
  type        = bool
  default     = false
}

variable "import_from_secret" {
  description = "If this is set to true, certificate is imported from provided SecretsManager secret."
  type        = bool
  default     = false
}


variable "common_name" {
  description = "The domain name that the certificate will be created for. Currently this value will be wild-carded."
  type        = string
}

variable "additional_secrets" {
  description = "Additonal key-value pairs to add to the created SecretsManager secret"
  type = map
  default = {}
}

variable "imported_certificate_filepath" {
  default = ""
}

variable "imported_certificate_chain_filepath" {
  default = ""
}

variable "imported_private_key_filepath" {
  default = ""
}


variable "secret_allowed_accounts" {
  type = list(number)
}


variable "create_secret_update_sns" {
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


variable "certificate_keyname" {
  type = string
  default = "CERTIFICATE"
}

variable "private_key_keyname" {
  type = string
  default = "CERTIFICATE_PRIVATE_KEY"
}

variable "certificate_chain_keyname" {
  type = string
  default = "CERTIFICATE_CHAIN"
}

