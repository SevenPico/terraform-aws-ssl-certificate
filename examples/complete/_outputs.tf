output "acm_certificate_cloudfront_region_arn" {
  value = module.ssl_certificate.acm_certificate_cloudfront_region_arn
  sensitive = true
}

output "acm_certificate_arn" {
  value = module.ssl_certificate.acm_certificate_arn
  sensitive = true
}

output "certificate_private_key_content" {
  value = module.ssl_certificate.certificate_private_key_content
  sensitive = true
}

output "certificate_content" {
  value = module.ssl_certificate.certificate_content
  sensitive = true
}

output "certificate_chain_content" {
  value = module.ssl_certificate.certificate_chain_content
  sensitive = true
}

output "kms_key_arn" {
  value = module.ssl_certificate.kms_key_arn
  sensitive = true
}

output "secretsmanager_certificate_private_key_keyname" {
  value = module.ssl_certificate.secretsmanager_certificate_private_key_keyname
}

output "secretsmanager_certificate_keyname" {
  value = module.ssl_certificate.secretsmanager_certificate_keyname
}

output "secretsmanager_certificate_chain_keyname" {
  value = module.ssl_certificate.secretsmanager_certificate_chain_keyname
}

output "secretsmanager_arn" {
  value = module.ssl_certificate.secretsmanager_arn
  sensitive = true
}

output "secretsmanager_id" {
  value = module.ssl_certificate.secretsmanager_id
}

# output "secretsmanager_version_arn" {
#   value = module.ssl_certificate.secretsmanager_version_arn
#   sensitive = true
# }
