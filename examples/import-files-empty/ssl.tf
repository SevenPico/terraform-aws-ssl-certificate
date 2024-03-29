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
##  ./examples/import-files-empty/ssl.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# SSL Certificate Context
# ------------------------------------------------------------------------------
module "ssl_certificate_import_context" {
  source  = "SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
}

# ------------------------------------------------------------------------------
# SSL Certificate Import
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  source  = "../.."
  context = module.ssl_certificate_import_context.self

  save_csr                            = var.save_csr
  additional_dns_names                = []
  additional_secrets                  = { EXAMPLE = "example value" }
  create_mode                         = "From_File"
  create_secret_update_sns            = true
  import_filepath_certificate         = "${path.module}/cert.pem"
  import_filepath_certificate_chain   = "${path.module}/chain.pem"
  import_filepath_csr                 = "${path.module}/csr.pem"
  import_filepath_private_key         = "${path.module}/key.pem"
  import_secret_arn                   = null
  keyname_certificate                 = "CERTIFICATE"
  keyname_certificate_chain           = "CERTIFICATE_CHAIN"
  keyname_certificate_signing_request = "CERTIFICATE_SIGNING_REQUEST"
  keyname_private_key                 = "CERTIFICATE_PRIVATE_KEY"
  kms_key_deletion_window_in_days     = 7
  kms_key_enable_key_rotation         = false
  secret_read_principals              = {}
  secret_update_sns_pub_principals = {
    RootAccess = {
      type        = "AWS"
      identifiers = [try(data.aws_caller_identity.current[0].account_id, "")]
      condition   = null
    }
  }
  secret_update_sns_sub_principals = {
    RootAccess = {
      type        = "AWS"
      identifiers = [try(data.aws_caller_identity.current[0].account_id, "")]
      condition   = null
    }
  }
  zone_id = aws_route53_zone.public[0].id
}
