terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.10.2"
    }
  }
  required_version = ">= 0.13"
}
