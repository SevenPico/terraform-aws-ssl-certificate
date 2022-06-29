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

output "keyname_certificate" {
  value = module.ssl_certificate.keyname_certificate
}

output "keyname_private_key" {
  value = module.ssl_certificate.keyname_private_key
}

output "keyname_certificate_chain" {
  value = module.ssl_certificate.keyname_certificate_chain
}
