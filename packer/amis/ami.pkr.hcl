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
  ami_name      = var.ami_name
  instance_type = "t2.micro"
  source_ami    = var.base_ami_id
  ssh_username  = "ec2-user"

  tags = {
    Environment = "Production"
  }
}

build {
  sources = ["source.amazon-ebs.custom-ami"]

  # install image
    
  provisioner "shell" {
    inline = [
      "sudo docker run -p 80:80 --name=${var.container_name} --restart always -d ${var.container_image}",
    ]
  }
  
}