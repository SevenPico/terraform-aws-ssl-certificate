# ------------------------------------------------------------------------------
#  SSL Secret Change SNS Topic
# ------------------------------------------------------------------------------
module "sns_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  enabled    = module.this.enabled && var.create_sns_topic
  attributes = ["sns"]
}

resource "aws_sns_topic" "this" {
  count = module.sns_meta.enabled ? 1 : 0

  name                        = module.sns_meta.id
  display_name                = module.sns_meta.id
  tags                        = module.sns_meta.tags
  kms_master_key_id           = ""
  delivery_policy             = null
  fifo_topic                  = false
  content_based_deduplication = false
}

resource "aws_sns_topic_policy" "this" {
  count = module.sns_meta.enabled ? 1 : 0

  arn    = one(aws_sns_topic.this[*].arn)
  policy = one(data.aws_iam_policy_document.sns[*].json)
}

data "aws_iam_policy_document" "sns" {
  count = module.sns_meta.enabled ? 1 : 0

  policy_id = module.sns_meta.id

  statement {
    sid       = "Allow Pub"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [one(aws_sns_topic.this[*].arn)]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com"
      ]
    }

    dynamic "principals" {
      for_each = var.sns_pub_principals
      content {
        type = principals.key
        identifiers = principals.value
      }
    }
  }

  statement {
    sid       = "Allow Sub"
    effect    = "Allow"
    actions   = ["SNS:Subscribe"]
    resources = [one(aws_sns_topic.this[*].arn)]

    dynamic "principals" {
      for_each = var.sns_sub_principals
      content {
        type = principals.key
        identifiers = principals.value
      }
    }
  }
}


# ------------------------------------------------------------------------------
#  Secret Change CloudWatch Event to SNS
# ------------------------------------------------------------------------------
module "sns_event_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.sns_meta.context
  attributes = ["event"]
}

resource "aws_cloudwatch_event_rule" "this" {
  count = module.sns_event_meta.enabled ? 1 : 0

  description = "Event on change of SSL secret value"
  name        = "${module.sns_event_meta.id}-rule"
  is_enabled  = true

  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"],
      eventName   = ["PutSecretValue", "UpdateSecret", "UpdateSecretVersionStage"]
      requestParameters = {
        secretId = [one(aws_secretsmanager_secret.ssl_certificate[*].arn)]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "ssl_event_target" {
  count = module.sns_event_meta.enabled ? 1 : 0

  rule      = one(aws_cloudwatch_event_rule.this[*].name)
  arn       = one(aws_sns_topic.this[*].arn)
  target_id = null
}
