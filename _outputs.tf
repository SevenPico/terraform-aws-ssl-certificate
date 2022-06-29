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
  value = local.secret_arn
}

output "acm_certificate_arn" {
  value = local.create_acm_only ? module.acm_only.arn : one(aws_acm_certificate.imported[*].arn)
}

output "acm_certificate_id" {
  value = local.create_acm_only ? module.acm_only.id : one(aws_acm_certificate.imported[*].id)
}

#output "certificate" {
#  value = local.certificate
#}

output "keyname_certificate" {
  value = var.keyname_certificate
}

#output "private_key" {
#  value = local.private_key
#}

output "keyname_private_key" {
  value = var.keyname_private_key
}

#output "certificate_chain" {
#  value = local.certificate_chain
#}

output "keyname_certificate_chain" {
  value = var.keyname_certificate_chain
}
