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
##  ./examples/letsencrypt/_outputs.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

output "kms_key_arn" {
  value = module.ssl_certificate.kms_key_arn
}

output "kms_key_alias_name" {
  value = module.ssl_certificate.kms_key_alias_name
}

output "kms_key_alias_arn" {
  value = module.ssl_certificate.kms_key_alias_arn
}

output "secret_arn" {
  value = module.ssl_certificate.secret_arn
}

output "acm_certificate_arn" {
  value = module.ssl_certificate.acm_certificate_arn
}

output "acm_certificate_id" {
  value = module.ssl_certificate.acm_certificate_id
}

output "acm_certificate_replica_arn" {
  value = module.ssl_certificate.acm_certificate_arn
}

output "acm_certificate_replica_id" {
  value = module.ssl_certificate.acm_certificate_id
}

output "keyname_certificate" {
  value = module.ssl_certificate.keyname_certificate
}

output "keyname_private_key" {
  value = module.ssl_certificate.keyname_private_key
}

output "keyname_certificate_chain" {
  value = module.ssl_certificate.keyname_certificate_chain
}
