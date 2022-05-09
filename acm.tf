locals {
  is_cloudfront_region = data.aws_region.current.name == "us-east-1"
}

# ------------------------------------------------------------------------------
# ACM Store
# ------------------------------------------------------------------------------
resource "aws_acm_certificate" "certificate" {
  count = module.certificate_secrets_meta.enabled ? 1 : 0

  certificate_body  = local.certificate
  certificate_chain = local.certificate_chain
  private_key       = local.private_key
  tags              = module.this.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}


# ------------------------------------------------------------------------------
# Duplicate ACM Store for Cloudfront
# ------------------------------------------------------------------------------
resource "aws_acm_certificate" "certificate_cloudfront_region" {
  count = (module.certificate_secrets_meta.enabled && !local.is_cloudfront_region) ? 1 : 0

  provider = aws.cloudfront

  certificate_body  = local.certificate
  certificate_chain = local.certificate_chain
  private_key       = local.private_key
  tags              = module.this.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}
