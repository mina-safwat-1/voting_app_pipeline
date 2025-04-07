# custom-ami.pkr.hcl

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "custom-ami" {
  region        = var.aws_region
  ami_name      = "vote-ami-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  instance_type = "t2.micro"
  source_ami    = var.base_ami_id
  ssh_username  = "ec2-user"
  iam_instance_profile = var.ec2_profile  # Name of your IAM profile

  tags = {
    service = "vote"
  }
}

build {
  sources = ["source.amazon-ebs.custom-ami"]

  # Install AWS CLI and authenticate with ECR
  provisioner "shell" {
    inline = [
      "sudo yum install -y aws-cli",  # Or use 'amazon-linux-extras install aws-cli' for Amazon Linux 2
      "aws ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${var.ecr_repository_url}",
    ]
  }

  # install image
  provisioner "shell" {
    inline = [
      "sudo docker container run -p 80:80 --name=vote-container -e REDIS_HOST=${var.REDIS_HOST}  --restart always -d ${var.container_image}",
    ]
  }

  # Add these post-processors at the end of your build block
  post-processor "manifest" {
    output     = "ami-manifest.json"
    strip_path = true
  }

  post-processor "shell-local" {
    inline = [
      "jq -r '.builds[].artifact_id' ami-manifest.json | cut -d':' -f2 > packer/amis/vote.txt",
      "echo 'AMI ID saved to ami-id.txt'",
      "rm ami-manifest.json",
    ]
  }


  
  }