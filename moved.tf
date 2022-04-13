moved {
  from = aws_acm_certificate.self_signed_certificate
  to   = aws_acm_certificate.certificate
}

moved {
  from = aws_acm_certificate.self_signed_certificate_cloudfront_region
  to   = aws_acm_certificate.certificate_cloudfront_region
}

moved {
  from = aws_secretsmanager_secret.self_signed_ssl_certificate
  to   = aws_secretsmanager_secret.ssl_certificate
}

moved {
  from = aws_secretsmanager_secret_version.self_signed_ssl_certificate
  to   = aws_secretsmanager_secret_version.ssl_certificate
}

moved {
  from = tls_private_key.self_signed_private_key
  to   = tls_private_key._private_key
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


/*
moved {
  from = aws_secretsmanager_secret_version.trusted_ca_ssl_certificate
  to   = aws_secretsmanager_secret_version.ssl_certificate
}

moved {
  from = aws_secretsmanager_secret.trusted_ca_ssl_certificate
  to   = aws_secretsmanager_secret.ssl_certificate
}

moved {
  from = aws_acm_certificate.trusted_ca_certificate
  to   = aws_acm_certificate.certificate
}

moved {
  from = aws_acm_certificate.trusted_ca_certificate_cloudfront_region
  to   = aws_acm_certificate.certificate_cloudfront_region
}

moved {
  from = aws_acm_certificate.trusted_ca_certificate
  to   = aws_acm_certificate.certificate
}
*/




# moved {
#   from = aws_secretsmanager_secret.self_signed_ssl_certificate
#   to   = aws_secretsmanager_secret.letsencrypt_ssl_certificate
# }

# moved {
#   from = aws_secretsmanager_secret_version.self_signed_ssl_certificate
#   to   = aws_secretsmanager_secret_version.letsencrypt_ssl_certificate
# }

# moved {
#   from = aws_acm_certificate.self_signed_certificate
#   to   = aws_acm_certificate.letsencrypt_certificate
# }

# moved {
#   from = aws_acm_certificate.self_signed_certificate_cloudfront_region
#   to   = aws_acm_certificate.letsencrypt_certificate_cloudfront_region
# }
