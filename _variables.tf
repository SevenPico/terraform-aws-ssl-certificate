#variable "create_acm_only" {
#  description = "If this is set to true, an AWS managed ACM will be created without any Secrets Manager document."
#  type        = bool
#  default     = false
#}
#
#variable "create_letsencrypt" {
#  description = "If this is set to true, Let's Encrypt certificate values will be created."
#  type        = bool
#  default     = false
#  validation {
#    condition = var.create_letsencrypt == false || (var.create_from_file
#    error_message = "Invalid List of IP addresses provided."
#  }
#}
#
#variable "create_from_file" {
#  description = "If this is set to true, certificate is imported from provided filepaths."
#  type        = bool
#  default     = false
#}
#
#variable "create_from_secret" {
#  description = "If this is set to true, certificate is imported from provided SecretsManager secret."
#  type        = bool
#  default     = false
#}
locals {
  create_acm_only    = var.create_mode == "ACM_Only" && module.this.enabled
  create_letsencrypt = var.create_mode == "LetsEncrypt" && module.this.enabled
  create_from_file   = var.create_mode == "From_File" && module.this.enabled
  create_from_secret = var.create_mode == "From_Secret" && module.this.enabled

  ignore_secret_changes = local.create_from_file
}

variable "create_mode" {
  type        = string
  description = "Set the operational mode of this module."
  default     = "LetsEncrypt"

  validation {
    condition     = contains(["ACM_Only", "LetsEncrypt", "From_Secret", "From_File"], var.create_mode)
    error_message = "The 'mode' must be one of [ACM_Only, LetsEncrypt, From_Secret, From_File]"
  }
}

variable "create_secret_update_sns" {
  type    = bool
  default = false
}

variable "import_secret_arn" {
  description = "ARN of exisiting SecretsManager secret containing certificate, private key and chain"
  type        = string
  default     = ""
}

variable "common_name" {
  description = "The domain name that the certificate will be created for. Currently this value will be wild-carded."
  type        = string
  default     = ""
}

variable "additional_secrets" {
  description = "Additonal key-value pairs to add to the created SecretsManager secret"
  type        = map(any)
  default     = {}
}

variable "keyname_certificate" {
  type    = string
  default = "CERTIFICATE"
}

variable "keyname_private_key" {
  type    = string
  default = "CERTIFICATE_PRIVATE_KEY"
}

variable "keyname_certificate_chain" {
  type    = string
  default = "CERTIFICATE_CHAIN"
}

variable "import_filepath_certificate" {
  default = ""
}

variable "import_filepath_certificate_chain" {
  default = ""
}

variable "import_filepath_private_key" {
  default = ""
}

variable "secret_allowed_accounts" {
  type    = list(number)
  default = []
}

variable "secret_update_sns_pub_principals" {
  type    = map(any)
  default = {}
}

variable "secret_update_sns_sub_principals" {
  type    = map(any)
  default = {}
}

variable "zone_id" {
  description = "When using ACM_Only, the Route53 Zone ID is required."
  type        = string
  default     = null
}
