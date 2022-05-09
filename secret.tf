module "certificate_secrets_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["secret"]
}

module "certificate_secrets_kms_key_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.certificate_secrets_meta.context
  attributes = ["kms", "key"]
}


#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret - KMS Keys
#--------------------------------------------------------------------------
data "aws_iam_policy_document" "kms_key_access_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  dynamic "statement" {
    for_each = toset(var.secret_allowed_accounts)
    content {
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = ["*"]

      principals {
        type = "AWS"
        identifiers = ["arn:aws:iam::${statement.value}:root"]
      }
    }

  }
}

resource "aws_kms_key" "this" {
  count                    = module.this.enabled ? 1 : 0
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  description              = "KMS key for ${module.this.id}"
  enable_key_rotation      = false
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = data.aws_iam_policy_document.kms_key_access_policy_doc.json
  tags                     = module.certificate_secrets_kms_key_meta.tags
}

resource "aws_kms_alias" "this" {
  count         = module.this.enabled ? 1 : 0
  name          = format("alias/%v", module.this.id)
  target_key_id = one(aws_kms_key.this[*].id)
}

#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret
#------------------------------------------------------------------------------
data "aws_iam_policy_document" "secret_access_policy_doc" {
  dynamic "statement" {
    for_each = toset(var.secret_allowed_accounts)
    content {
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]

      principals {
        type = "AWS"
        identifiers = ["arn:aws:iam::${statement.value}:root"]
      }
    }
  }
}

resource "aws_secretsmanager_secret" "ssl_certificate" {
  count       = (module.certificate_secrets_meta.enabled && !local.prevent_destroy_secret) ? 1 : 0
  name_prefix = "${module.certificate_secrets_meta.id}-"
  tags        = module.certificate_secrets_meta.tags
  kms_key_id  = one(aws_kms_key.this[*].key_id)
  description = "SSL Certificate Values"
  policy      = data.aws_iam_policy_document.secret_access_policy_doc.json
}

resource "aws_secretsmanager_secret_version" "ssl_certificate" {
  count     = (module.certificate_secrets_meta.enabled && !local.prevent_destroy_secret) ? 1 : 0
  secret_id = aws_secretsmanager_secret.ssl_certificate[0].id

  secret_string = jsonencode(merge({
    "${var.secretsmanager_certificate_keyname}"             = local.certificate
    "${var.secretsmanager_certificate_chain_keyname}"       = local.certificate_chain
    "${var.secretsmanager_certificate_private_key_keyname}" = local.private_key
  }, var.additional_certificate_secrets))

  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}


#------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret (Prevent Destroy)
#------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "ssl_certificate_prevent_destroy" {
  count       = (module.certificate_secrets_meta.enabled && local.prevent_destroy_secret) ? 1 : 0
  name_prefix = "${module.certificate_secrets_meta.id}-"
  tags        = module.certificate_secrets_meta.tags
  kms_key_id  = one(aws_kms_key.this[*].key_id)
  description = "SSL Certificate Values"

  # no prevent_destroy for letsencrypt
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "ssl_certificate_prevent_destroy" {
  count     = (module.certificate_secrets_meta.enabled && local.prevent_destroy_secret) ? 1 : 0
  secret_id = aws_secretsmanager_secret.ssl_certificate[0].id
  secret_string = jsonencode(merge({
    "${var.secretsmanager_certificate_keyname}"             = local.certificate
    "${var.secretsmanager_certificate_chain_keyname}"       = local.certificate_chain
    "${var.secretsmanager_certificate_private_key_keyname}" = local.private_key
  }, var.additional_certificate_secrets))

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [secret_string, secret_binary]
  }
}
