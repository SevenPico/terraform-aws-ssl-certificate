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
##  ./examples/import-files/ssl.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# SSL Certificate Context
# ------------------------------------------------------------------------------
module "ssl_certificate_source_context" {
  source  = "SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
}

module "ssl_certificate_import_context" {
  source     = "SevenPico/context/null"
  version    = "2.0.0"
  context    = module.ssl_certificate_source_context.self
  attributes = ["import"]
}


# ------------------------------------------------------------------------------
# SSL Certificate Source
# ------------------------------------------------------------------------------
module "ssl_certificate_source" {
  source  = "../.."
  context = module.ssl_certificate_source_context.self

  additional_secrets                  = { EXAMPLE = "example value" }
  create_mode                         = "LetsEncrypt"
  create_secret_update_sns            = true
  import_filepath_certificate         = null
  import_filepath_certificate_chain   = null
  import_filepath_csr                 = null
  import_filepath_private_key         = null
  import_secret_arn                   = null
  keyname_certificate                 = "CERTIFICATE"
  keyname_certificate_chain           = "CERTIFICATE_CHAIN"
  keyname_certificate_signing_request = "CERTIFICATE_SIGNING_REQUEST"
  keyname_private_key                 = "CERTIFICATE_PRIVATE_KEY"
  kms_key_deletion_window_in_days     = 7
  kms_key_enable_key_rotation         = false
  save_csr                            = var.save_csr
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
  zone_id = null

}

data "aws_secretsmanager_secret" "source" {
  count      = module.context.enabled ? 1 : 0
  depends_on = [module.ssl_certificate_source]

  arn = module.ssl_certificate_source.secret_arn
}
data "aws_secretsmanager_secret_version" "source" {
  count      = module.context.enabled ? 1 : 0
  depends_on = [module.ssl_certificate_source]

  secret_id     = data.aws_secretsmanager_secret.source[0].id
  version_stage = "AWSCURRENT"
}

resource "local_file" "key" {
  count    = module.context.enabled ? 1 : 0
  filename = "${path.module}/key.pem"
  content  = jsondecode(data.aws_secretsmanager_secret_version.source[0].secret_string)[module.ssl_certificate_source.keyname_private_key]
}

resource "local_file" "certificate" {
  count    = module.context.enabled ? 1 : 0
  filename = "${path.module}/cert.pem"
  content  = jsondecode(data.aws_secretsmanager_secret_version.source[0].secret_string)[module.ssl_certificate_source.keyname_certificate]
}

resource "local_file" "certificate_chain" {
  count    = module.context.enabled ? 1 : 0
  filename = "${path.module}/chain.pem"
  content  = jsondecode(data.aws_secretsmanager_secret_version.source[0].secret_string)[module.ssl_certificate_source.keyname_certificate_chain]
}


# ------------------------------------------------------------------------------
# SSL Certificate Import
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  source     = "../.."
  context    = module.ssl_certificate_import_context.self
  depends_on = [module.ssl_certificate_source, local_file.certificate, local_file.certificate_chain, local_file.key]

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
  save_csr                            = var.save_csr
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
  zone_id = null
}
