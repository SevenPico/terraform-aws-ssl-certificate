output "kms_key_arn" {
  value = module.ssl_certificates_kms_key.key_arn
}

output "acm_certificate_arn" {
  value = var.ssl_certificate_create_self_signed ? aws_acm_certificate.self_signed_certificate[0].arn : aws_acm_certificate.trusted_ca_certificate[0].arn
}

locals {
  acm_trusted_ca_cloudfront_region_arn       = !local.is_cloudfront_region && !var.ssl_certificate_create_self_signed ? aws_acm_certificate.trusted_ca_certificate_cloudfront_region : null
  acm_self_signed_cloudfront_region_arn      = !local.is_cloudfront_region && var.ssl_certificate_create_self_signed ? aws_acm_certificate.self_signed_certificate_cloudfront_region : null
  acm_trusted_ca_arn                         = local.is_cloudfront_region && !var.ssl_certificate_create_self_signed ? aws_acm_certificate.trusted_ca_certificate : null
  acm_self_signed_arn                        = local.is_cloudfront_region && var.ssl_certificate_create_self_signed ? aws_acm_certificate.self_signed_certificate : null

  temp_acm_certificate_cloudfront_region_arn = coalesce(local.acm_trusted_ca_cloudfront_region_arn, local.acm_self_signed_cloudfront_region_arn, local.acm_trusted_ca_arn, local.acm_self_signed_arn)
  acm_certificate_cloudfront_region_arn      = length(local.temp_acm_certificate_cloudfront_region_arn) > 0 ? local.temp_acm_certificate_cloudfront_region_arn[0].arn : null
}

output "acm_certificate_cloudfront_region_arn" {
  value = local.acm_certificate_cloudfront_region_arn
}

output "secretsmanager_arn" {
  value = data.aws_secretsmanager_secret.ssl_certificate_values[0].arn
}

output "secretsmanager_id" {
  value = data.aws_secretsmanager_secret.ssl_certificate_values[0].id
}

output "secretsmanager_version_arn" {
  value = data.aws_secretsmanager_secret_version.ssl_certificate_values[0].arn
}

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
  value = local.ssl_certificate
}

output "certificate_private_key_content" {
  value = local.ssl_private_key
}

output "certificate_chain_content" {
  value = local.ssl_certificate_chain
}
