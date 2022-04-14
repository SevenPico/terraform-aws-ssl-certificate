output "kms_key_arn" {
  value = module.ssl_certificates_kms_key.key_arn
}

output "acm_certificate_arn" {
  value = join("", aws_acm_certificate.certificate[*].arn)
}

output "acm_certificate_cloudfront_region_arn" {
  value = join("", aws_acm_certificate.certificate_cloudfront_region[*].arn)
}

output "secretsmanager_arn" {
  value = join("", aws_secretsmanager_secret.ssl_certificate[*].arn)
}

output "secretsmanager_id" {
  value = join("", aws_secretsmanager_secret.ssl_certificate[*].id)
}

# output "secretsmanager_version_arn" {
#   value = join("", aws_secretsmanager_secret_version.ssl_certificate[*].arn)
# }

output "secretsmanager_certificate_chain_keyname" {
  value = var.ssl_certificate_secretsmanager_certificate_chain_keyname
}

output "secretsmanager_certificate_keyname" {
  value = var.ssl_certificate_secretsmanager_certificate_keyname
}

output "secretsmanager_certificate_private_key_keyname" {
  value = var.ssl_certificate_secretsmanager_certificate_private_key_keyname
}

output "certificate_content" {
  value = local.certificate
}

output "certificate_private_key_content" {
  value = local.private_key
}

output "certificate_chain_content" {
  value = local.certificate_chain
}
