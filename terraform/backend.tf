terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


  backend "s3" {
    bucket       = "voting-app-pipeline-state"
    region       = "us-east-1"
    key          = "terraform.tfstate"
    use_lockfile = true
  }
}
