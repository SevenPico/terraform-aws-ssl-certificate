terraform {
  required_version = "~> 1.1.5"
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.8.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.52.0"
    }
    # template = {
    #   source  = "hashicorp/template"
    #   version = "~> 2.2.0"
    # }
    # local = {
    #   source  = "hashicorp/local"
    #   version = "~> 2.1.0"
    # }
    # null = {
    #   source  = "hashicorp/null"
    #   version = "~> 3.1.0"
    # }
    # archive = {
    #   source  = "hashicorp/archive"
    #   version = "~> 2.2.0"
    # }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.1.0"
    # }
    # time = {
    #   source  = "hashicorp/time"
    #   version = "~> 0.7.2"
    # }
  }
}
