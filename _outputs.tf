output "kms_key_arn" {
  value = one(aws_kms_key.this[*].arn)
}

output "kms_key_alias" {
  value = one(aws_kms_alias.this[*].name)
}


output "secretsmanager_arn" {
  value = one(aws_secretsmanager_secret.this[*].arn)
}

output "secretsmanager_id" {
  value = one(aws_secretsmanager_secret.this[*].id)
}


output "acm_certificate_arn" {
  value = one(aws_acm_certificate.default[*].arn)
}

output "acm_certificate_cloudfront_region_arn" {
  value = one(aws_acm_certificate.cloudfront[*].arn)
}


output "certificate" {
  value = local.certificate
}

output "private_key" {
  value = local.private_key
}

output "certificate_chain" {
  value = local.certificate_chain
}
