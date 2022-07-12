# ------------------------------------------------------------------------------
# Let's Encrypt Certificate
# ------------------------------------------------------------------------------
module "letsencrypt_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  enabled    = module.this.enabled && local.create_letsencrypt
  attributes = ["letsencrypt"]
}

resource "tls_private_key" "account_key" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  algorithm = "RSA"
}

resource "acme_registration" "this" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  account_key_pem = tls_private_key.account_key[0].private_key_pem
  email_address   = "nobody@${var.common_name}"
}

resource "tls_private_key" "certificate_key" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  algorithm = "RSA"
}

resource "tls_cert_request" "this" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  private_key_pem = tls_private_key.certificate_key[0].private_key_pem
  dns_names       = [var.common_name, "*.${var.common_name}"]

  subject {
    common_name = "*.${var.common_name}"
  }
}

resource "acme_certificate" "this" {
  count = module.letsencrypt_meta.enabled ? 1 : 0

  account_key_pem         = acme_registration.this[0].account_key_pem
  certificate_request_pem = tls_cert_request.this[0].cert_request_pem

  dns_challenge {
    provider = "route53"

    config = var.route53_user_enabled ? {
      AWS_ACCESS_KEY_ID = "${one(aws_iam_access_key.route53[*].id)}"
      AWS_SECRET_ACCESS_KEY = "${one(aws_iam_access_key.route53[*].secret)}"
    } : {}

  }
}

// Create the Route53 Terraform IAM User, allowing Terraform to add the DNS record for an ACME cert issuance.
// Needed due to https://github.com/vancluever/terraform-provider-acme/issues/203 .
resource "aws_iam_user" "route53" {
  count = var.route53_user_enabled ? 1 : 0
  name = "route53_ssl"
}

resource "aws_iam_access_key" "route53" {
  count = var.route53_user_enabled ? 1 : 0
  user = one(aws_iam_user.route53[*].name)
}

resource "aws_iam_user_policy" "route53" {
  count = var.route53_user_enabled ? 1 : 0
  name = "terraform_route_53_user_policy"
  user = one(aws_iam_user.route53[*].name)

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
          "route53:GetChange",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource": [
          "arn:aws:route53:::hostedzone/*",
          "arn:aws:route53:::change/*"
        ]
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": "route53:ListHostedZonesByName",
        "Resource": "*"
      }
    ]
  })
}
