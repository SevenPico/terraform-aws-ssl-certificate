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
