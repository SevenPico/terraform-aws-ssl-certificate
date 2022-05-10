# ------------------------------------------------------------------------------
# ACM Store
# ------------------------------------------------------------------------------
resource "aws_acm_certificate" "default" {
  count = module.this.enabled ? 1 : 0

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
# Duplicate ACM Store for Cloudfront in us-east-1 (if needed)
# ------------------------------------------------------------------------------
locals {
  is_cloudfront_region = data.aws_region.current.name == "us-east-1"
}

resource "aws_acm_certificate" "cloudfront" {
  count = (module.this.enabled && !local.is_cloudfront_region) ? 1 : 0

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
