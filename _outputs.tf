output "kms_key_arn" {
  value = one(aws_kms_key.this[*].arn)
}

output "kms_key_alias_name" {
  value = one(aws_kms_alias.this[*].name)
}

output "kms_key_alias_arn" {
  value = one(aws_kms_alias.this[*].arn)
}

output "secret_arn" {
  value = one(aws_secretsmanager_secret.this[*].arn)
}

output "secret_id" {
  value = one(aws_secretsmanager_secret.this[*].id)
}


output "acm_certificate_arn" {
  value = one(aws_acm_certificate.default[*].arn)
}

output "acm_certificate_cloudfront_arn" {
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
