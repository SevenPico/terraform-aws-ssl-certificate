output "kms_key_arn" {
  value = module.ssl_secret.kms_key_arn
}

output "kms_key_alias_name" {
  value = module.ssl_secret.kms_key_alias_name
}

output "kms_key_alias_arn" {
  value = module.ssl_secret.kms_key_alias_arn
}

output "sns_topic_arn" {
  value = module.ssl_secret.sns_topic_arn
}

output "secret_arn" {
  value = local.secret_arn
}

output "acm_certificate_arn" {
  value = local.create_acm_only ? module.acm_only.arn : one(aws_acm_certificate.imported[*].arn)
}

output "acm_certificate_id" {
  value = local.create_acm_only ? module.acm_only.id : one(aws_acm_certificate.imported[*].id)
}

output "keyname_certificate" {
  value = var.keyname_certificate
}

output "keyname_private_key" {
  value = var.keyname_private_key
}

output "keyname_certificate_chain" {
  value = var.keyname_certificate_chain
}
