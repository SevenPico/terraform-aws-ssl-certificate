moved {
  from = tls_private_key.self_signed_private_key
  to   = tls_private_key.letsencrypt_private_key
}

moved {
  from = tls_private_key.self_signed_certificate_private_key
  to   = tls_private_key.letsencrypt_certificate_private_key
}

moved {
  from = tls_cert_request.self_signed_certificate_request
  to   = tls_cert_request.letsencrypt_certificate_request
}

moved {
  from = acme_certificate.self_signed_acme_certificate
  to   = acme_certificate.letsencrypt_acme_certificate
}

moved {
  from = aws_secretsmanager_secret.self_signed_ssl_certificate
  to   = aws_secretsmanager_secret.letsencrypt_ssl_certificate
}

moved {
  from = aws_secretsmanager_secret_version.self_signed_ssl_certificate
  to   = aws_secretsmanager_secret_version.letsencrypt_ssl_certificate
}

moved {
  from = aws_acm_certificate.self_signed_certificate
  to   = aws_acm_certificate.letsencrypt_certificate
}

moved {
  from = aws_acm_certificate.self_signed_certificate_cloudfront_region
  to   = aws_acm_certificate.letsencrypt_certificate_cloudfront_region
}
