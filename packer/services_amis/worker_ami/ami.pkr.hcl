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
  region        = "us-east-1"
  ami_name      = "worker-ami-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  instance_type = "t2.micro"
  source_ami    = var.base_ami_id
  ssh_username  = "ec2-user"

  tags = {
    service = "worker"
  }
}

build {
  sources = ["source.amazon-ebs.custom-ami"]

  # install image
  provisioner "shell" {
    inline = [
      "sudo docker run -p 3000:80 --name=worker-container -e DB_USER=${var.DB_USER} -e DB_PASSWORD=${var.DB_PASSWORD} -e DB_HOST=${var.DB_HOST} -e REDIS_HOST=${var.REDIS_HOST} --restart always -d ${var.container_image}",
    ]
  }
  

  }