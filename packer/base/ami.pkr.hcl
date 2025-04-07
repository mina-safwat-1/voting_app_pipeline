# custom-ami.pkr.hcl

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


data "amazon-ami" "amazon_linux_2023" {
  filters = {
    virtualization-type = "hvm"
    name                = "al2023-ami-*-kernel-6.1-x86_64"
    root-device-type    = "ebs"
  }
  most_recent = true
  owners      = ["amazon"]
}

source "amazon-ebs" "custom-ami" {
  region        = var.aws_region
  ami_name      = "base-ami-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  instance_type = "t2.micro"
  source_ami    = data.amazon-ami.amazon_linux_2023.id
  ssh_username  = "ec2-user"

  tags = {
    Environment = "Production"
  }
}

build {
  sources = ["source.amazon-ebs.custom-ami"]

  # Provisioning commands

  # install docker
  provisioner "shell" {
    inline = [

      # Update package cache (Amazon Linux)
      "sudo yum update -y",

      # Install Docker
      "sudo yum install -y docker",

      # Start and enable Docker service
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      # Add user to docker group (Amazon Linux uses 'ec2-user')
      "sudo usermod -aG docker ec2-user",

      # Verify Docker installation
      "docker --version",

      # Clean up package cache
      "sudo yum clean all"
    ]
  }

  # copy node_exporter.service file to ami
  provisioner "file" {
    source      = "./packer/base/node_exporter.service"
    destination = "/tmp/node_exporter.service"
  }


  provisioner "shell" {
    inline = [
      # Download Node Exporter
      "sudo yum install -y wget tar",
      "cd /tmp/",
      "wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz",
      "tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz",
      "cd node_exporter-1.3.1.linux-amd64",

      # create a node_exporter user
      "sudo useradd --no-create-home --shell /bin/false node_exporter",

      # move files and change permissions
      "sudo mv node_exporter /usr/local/bin/",
      "sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter",

      # create a systemd service file
      "sudo mv /tmp/node_exporter.service /etc/systemd/system/node_exporter.service",

      # start a systemd service
      "sudo systemctl daemon-reload",
      "sudo systemctl start node_exporter",
      "sudo systemctl enable node_exporter",
      "sudo systemctl status node_exporter"

    ]
  }

  # install cadvisor to ami
  provisioner "shell" {
    inline = [
      "sudo docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --detach=true --name=cadvisor --privileged --device=/dev/kmsg --restart always gcr.io/cadvisor/cadvisor",
    ]
  }


  # Add these post-processors at the end of your build block
  post-processor "manifest" {
    output     = "ami-manifest.json"
    strip_path = true
  }

  post-processor "shell-local" {
    inline = [
      "jq -r '.builds[].artifact_id' ami-manifest.json | cut -d':' -f2 > packer/amis/base.txt",
      "echo 'AMI ID saved to ami-id.txt'",
      "rm ami-manifest.json",
    ]
  }




}