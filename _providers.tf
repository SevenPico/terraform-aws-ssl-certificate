provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "aws" {
  alias  = "cloudfront"
  region = "us-east-1"
}
