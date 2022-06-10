# ------------------------------------------------------------------------------
# SSL Certificate SecretsManager Secret
# --------------------------------------------------------------------------
module "secret_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  enabled    = module.this.enabled && local.create_secret
  attributes = ["secret"]
}

module "secret_kms_key_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.secret_meta.context
  attributes = ["kms", "key"]
}


# ------------------------------------------------------------------------------
# KMS Key
# --------------------------------------------------------------------------
data "aws_iam_policy_document" "kms_key_access_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
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
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value}:root"]
      }
    }
  }
}

resource "aws_kms_key" "this" {
  count = module.secret_kms_key_meta.enabled ? 1 : 0

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  description              = "KMS key for ${module.this.id}"
  enable_key_rotation      = false
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = data.aws_iam_policy_document.kms_key_access_policy_doc.json
  tags                     = module.secret_kms_key_meta.tags
}

resource "aws_kms_alias" "this" {
  count = module.secret_kms_key_meta.enabled ? 1 : 0

  name          = format("alias/%v", module.this.id)
  target_key_id = one(aws_kms_key.this[*].id)
}


# ------------------------------------------------------------------------------
# Secret
# ------------------------------------------------------------------------------
locals {
  secrets = {
    "${var.certificate_keyname}"       = local.certificate
    "${var.certificate_chain_keyname}" = local.certificate_chain
    "${var.private_key_keyname}"       = local.private_key

    ACM_ARN    = one(aws_acm_certificate.default[*].arn)
  }
}

data "aws_iam_policy_document" "secret_access_policy_doc" {
  count = length(var.secret_allowed_accounts) > 0 ? 1 : 0
  dynamic "statement" {
    for_each = toset(var.secret_allowed_accounts)
    content {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:DescribeSecret"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value}:root"]
      }
    }
  }
}

resource "aws_secretsmanager_secret" "this" {
  count = module.secret_meta.enabled ? 1 : 0

  description = "SSL Certificate Values"
  kms_key_id  = one(aws_kms_key.this[*].key_id)
  name_prefix = "${module.secret_meta.id}-"
  policy      = join("", data.aws_iam_policy_document.secret_access_policy_doc[*].json)
  tags        = module.secret_meta.tags
}

resource "aws_secretsmanager_secret_version" "default" {
  count = (module.secret_meta.enabled && !var.ignore_secret_changes) ? 1 : 0

  secret_id     = one(aws_secretsmanager_secret.this[*].id)
  secret_string = jsonencode(merge(local.secrets, var.additional_secrets))
}

resource "aws_secretsmanager_secret_version" "ignore_changes" {
  count = (module.secret_meta.enabled && var.ignore_secret_changes) ? 1 : 0

  secret_id     = one(aws_secretsmanager_secret.this[*].id)
  secret_string = jsonencode(merge(local.secrets, var.additional_secrets))

  lifecycle {
    ignore_changes = [secret_string, secret_binary]
  }
}
