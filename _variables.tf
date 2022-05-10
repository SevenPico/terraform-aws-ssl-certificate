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

variable "import_secret_arn" {
  description = "ARN of exisiting SecretsManager secret containing certificate, private key and chain"
  type = string
  default = ""
}

variable "common_name" {
  description = "The domain name that the certificate will be created for. Currently this value will be wild-carded."
  type        = string
}

variable "additional_secrets" {
  description = "Additonal key-value pairs to add to the created SecretsManager secret"
  type        = map(any)
  default     = {}
}

variable "certificate_keyname" {
  type    = string
  default = "CERTIFICATE"
}

variable "private_key_keyname" {
  type    = string
  default = "CERTIFICATE_PRIVATE_KEY"
}

variable "certificate_chain_keyname" {
  type    = string
  default = "CERTIFICATE_CHAIN"
}

variable "import_certificate_filepath" {
  default = ""
}

variable "import_certificate_chain_filepath" {
  default = ""
}

variable "import_private_key_filepath" {
  default = ""
}

variable "secret_allowed_accounts" {
  type = list(number)
}

variable "ignore_secret_changes" {
  description = "Add ignore_change on SecretsManager secret values to allow later replacement of the secret"
  type = bool
  default = false
}

variable "create_secret_update_sns" {
  type    = bool
  default = false
}

variable "secret_update_sns_pub_principals" {
  type    = map(any)
  default = {}
}

variable "secret_update_sns_sub_principals" {
  type    = map(any)
  default = {}
}

