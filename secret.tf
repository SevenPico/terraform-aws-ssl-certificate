## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./secret.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

locals {
  create_secret = local.create_letsencrypt || local.create_from_file

  letsencrypt_certificate = one(acme_certificate.this[*].certificate_pem)
  letsencrypt_private_key = one(tls_private_key.certificate_key[*].private_key_pem)
  letsencrypt_certificate_chain = join("", flatten([
    acme_certificate.this[*].certificate_pem,
    acme_certificate.this[*].issuer_pem
  ]))

  imported_file_certificate       = local.create_from_file && var.import_filepath_certificate != "" ? file(var.import_filepath_certificate) : ""
  imported_file_private_key       = local.create_from_file && var.import_filepath_private_key != "" ? file(var.import_filepath_private_key) : ""
  imported_file_certificate_chain = local.create_from_file && var.import_filepath_certificate_chain != "" ? file(var.import_filepath_certificate_chain) : ""

  certificate_to_save = local.create_from_file ? local.imported_file_certificate : (
  local.create_letsencrypt ? local.letsencrypt_certificate : "")
  certificate_chain_to_save = local.create_from_file ? local.imported_file_certificate_chain : (
  local.create_letsencrypt ? local.letsencrypt_certificate_chain : "")
  private_key_to_save = local.create_from_file ? local.imported_file_private_key : (
  local.create_letsencrypt ? local.letsencrypt_private_key : "")

  secrets = {
    "${var.keyname_certificate}"       = local.certificate_to_save
    "${var.keyname_certificate_chain}" = local.certificate_chain_to_save
    "${var.keyname_private_key}"       = local.private_key_to_save
  }
}


# --------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret
# --------------------------------------------------------------------------
module "ssl_secret" {
  source  = "SevenPico/secret/aws"
  version = "3.1.0"
  context = module.context.self
  enabled = module.context.enabled && local.create_secret

  create_sns                      = var.create_secret_update_sns && !local.create_acm_only
  description                     = "SSL Certificate and Private Key"
  kms_key_deletion_window_in_days = var.kms_key_deletion_window_in_days
  kms_key_enable_key_rotation     = var.kms_key_enable_key_rotation
  secret_ignore_changes           = local.ignore_secret_changes
  secret_read_principals          = var.secret_read_principals
  secret_string                   = jsonencode(merge(local.secrets, var.additional_secrets))
  sns_pub_principals              = var.secret_update_sns_pub_principals
  sns_sub_principals              = var.secret_update_sns_sub_principals
}
