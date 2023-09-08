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
##  ./examples/letsencrypt/ssl.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

locals {
  multi_region_enabled = local.region != "us-east-1"
}
# ------------------------------------------------------------------------------
# SSL Certificate Context
# ------------------------------------------------------------------------------
module "ssl_certificate_context" {
  source  = "SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
}


# ------------------------------------------------------------------------------
# KMS Key
# ------------------------------------------------------------------------------
module "kms_key" {
  source  = "SevenPicoForks/kms-key/aws"
  version = "2.0.0"
  context = module.context.self

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  description              = "KMS key for ${module.context.id}"
  enable_key_rotation      = true
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = local.multi_region_enabled
  policy                   = "" #try(data.aws_iam_policy_document.kms_key_access_policy_doc[0].json, "")
}

resource "aws_kms_replica_key" "secondary" {
  provider        = aws.us-east-1
  count           = module.context.enabled && local.multi_region_enabled ? 1 : 0
  description     = "Multi-region replica key for Secrets Manager in us-east-1"
  primary_key_arn = module.kms_key.key_arn

}


# ------------------------------------------------------------------------------
# SSL Certificate
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  source     = "../.."
  context    = module.ssl_certificate_context.self
  depends_on = [module.kms_key]

  replica_regions = local.multi_region_enabled ? ["us-east-1"] : []
  kms_key_id      = module.kms_key.key_id
  kms_key_enabled = false

  save_csr                            = var.save_csr
  additional_dns_names                = []
  additional_secrets                  = { EXAMPLE = "example value" }
  create_mode                         = "LetsEncrypt"
  create_secret_update_sns            = true
  create_wildcard                     = true
  import_filepath_certificate         = null
  import_filepath_certificate_chain   = null
  import_filepath_csr                 = null
  import_filepath_private_key         = null
  import_secret_arn                   = null
  keyname_certificate                 = "CERTIFICATE"
  keyname_certificate_chain           = "CERTIFICATE_CHAIN"
  keyname_certificate_signing_request = "CERTIFICATE_SIGNING_REQUEST"
  keyname_private_key                 = "CERTIFICATE_PRIVATE_KEY"
  registration_email_address          = ""
  secret_read_principals = {
    AllowRootRead = {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
      condition = {
        test = null
        values = [
        ]
        variable = null
      }
    }
  }
  secret_update_sns_pub_principals    = {}
  secret_update_sns_sub_principals    = {}
  zone_id                             = null
}

module "ssl_certificate_us_east_1" {
  providers = {
    aws = aws.us-east-1
  }
  source  = "../.."
  context = module.ssl_certificate_context.self
  depends_on = [
    module.ssl_certificate,
    aws_kms_replica_key.secondary
  ]

  replica_regions = []
  kms_key_id      = module.kms_key.key_id
  kms_key_enabled = false

  save_csr                            = var.save_csr
  additional_dns_names                = []
  additional_secrets                  = { EXAMPLE = "example value" }
  create_mode                         = "From_Secret"
  create_secret_update_sns            = false
  create_wildcard                     = true
  import_filepath_certificate         = null
  import_filepath_certificate_chain   = null
  import_filepath_csr                 = null
  import_filepath_private_key         = null
  import_secret_arn                   = replace(module.ssl_certificate.secret_arn, local.region, "us-east-1")
  keyname_certificate                 = "CERTIFICATE"
  keyname_certificate_chain           = "CERTIFICATE_CHAIN"
  keyname_certificate_signing_request = "CERTIFICATE_SIGNING_REQUEST"
  keyname_private_key                 = "CERTIFICATE_PRIVATE_KEY"
  registration_email_address          = ""
  secret_read_principals = {
    AllowRootRead = {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
      condition = {
        test = null
        values = [
        ]
        variable = null
      }
    }
  }
  secret_update_sns_pub_principals    = {}
  secret_update_sns_sub_principals    = {}
  zone_id                             = null
}


#------------------------------------------------------------------------------
# Certbot Context
#------------------------------------------------------------------------------
module "certbot_context" {
  source  = "registry.terraform.io/SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
  name    = "certbot"
}


#------------------------------------------------------------------------------
# Certbot
#------------------------------------------------------------------------------
module "certbot" {
  source  = "registry.terraform.io/SevenPico/certbot/aws"
  version = "1.0.4"
  context = module.certbot_context.self
  depends_on = [
    module.ssl_certificate,
    module.ssl_certificate_us_east_1,
  ]

  acm_certificate_arn                            = module.ssl_certificate.acm_certificate_arn
  ssl_secret_keyname_certificate                 = "CERTIFICATE"
  ssl_secret_keyname_certificate_chain           = "CERTIFICATE_CHAIN"
  ssl_secret_keyname_certificate_signing_request = "CERTIFICATE_SIGNING_REQUEST"
  ssl_secret_keyname_private_key                 = "CERTIFICATE_PRIVATE_KEY"
  target_secret_kms_key_arn                      = module.ssl_certificate.kms_key_arn
  target_secret_arn                              = module.ssl_certificate.secret_arn
  vpc_id                                         = module.vpc.vpc_id
  vpc_private_subnet_ids                         = module.vpc_subnets.private_subnet_ids
  reserved_concurrent_executions                 = -1
}


#------------------------------------------------------------------------------
# SSL Update Context
#------------------------------------------------------------------------------
module "ssl_updater_context" {
  source  = "SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
}


#------------------------------------------------------------------------------
# SSL Updater
#------------------------------------------------------------------------------
module "ssl_updater" {
  #  source     = "registry.terraform.io/SevenPico/ssl-update/aws"
#  version    = "0.1.2"
  source = "git::https://github.com/SevenPico/terraform-aws-ssl-update.git?ref=hotfix/fix_sns_topic_subscription"
  context    = module.ssl_updater_context.self
  depends_on = [module.certbot]
  attributes = ["ssl", "updater"]

  sns_topic_arn                 = module.ssl_certificate.sns_topic_arn
  acm_certificate_arn           = module.ssl_certificate.acm_certificate_arn
  cloudwatch_log_retention_days = 30
  ecs_cluster_arn               = ""
  ecs_service_arns              = []
  keyname_certificate           = "CERTIFICATE"
  keyname_certificate_chain     = "CERTIFICATE_CHAIN"
  keyname_private_key           = "CERTIFICATE_PRIVATE_KEY"
  kms_key_arn                   = module.ssl_certificate.kms_key_arn
  secret_arn                    = module.ssl_certificate.secret_arn
  ssm_adhoc_command             = ""
  ssm_named_document            = ""
  ssm_target_key                = "tag:Name"
  ssm_target_values             = []
}

module "ssl_updater_us_east_1" {
  providers = {
    aws = aws.us-east-1
  }
#  source     = "registry.terraform.io/SevenPico/ssl-update/aws"
#  version    = "0.1.2"
  source = "git::https://github.com/SevenPico/terraform-aws-ssl-update.git?ref=hotfix/fix_sns_topic_subscription"
  context    = module.ssl_updater_context.self
  enabled    = module.context.enabled && local.multi_region_enabled
  depends_on = [module.certbot]
  attributes = ["ssl", "updater", "us-east-1"]

  sns_topic_arn                 = module.ssl_certificate.sns_topic_arn
  acm_certificate_arn           = module.ssl_certificate_us_east_1.acm_certificate_arn
  cloudwatch_log_retention_days = 30
  ecs_cluster_arn               = ""
  ecs_service_arns              = []
  keyname_certificate           = "CERTIFICATE"
  keyname_certificate_chain     = "CERTIFICATE_CHAIN"
  keyname_private_key           = "CERTIFICATE_PRIVATE_KEY"
  kms_key_arn                   = module.ssl_certificate.kms_key_arn
  secret_arn                    = replace(module.ssl_certificate.secret_arn, local.region, "us-east-1")
  ssm_adhoc_command             = ""
  ssm_named_document            = ""
  ssm_target_key                = "tag:Name"
  ssm_target_values             = []

}

resource "aws_sns_topic_subscription" "lambda" {
  count     = module.context.enabled ? 1 : 0
  endpoint  = module.ssl_updater_us_east_1.function_arn
  protocol  = "lambda"
  topic_arn = module.ssl_certificate.sns_topic_arn
}

resource "aws_lambda_permission" "sns" {
  provider      = aws.us-east-1
  count         = module.context.enabled ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = module.ssl_updater_us_east_1.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.ssl_certificate.sns_topic_arn
  statement_id  = "AllowExecutionFromSNS"
}