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
  ami_name      = "${var.service_name}-ami-${timestamp()}"
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
      "sudo docker run -p 3000:80 --name=${var.container_name} --restart always -d ${var.container_image}",
    ]
  }

  # configure nginx to be suitable for elb
  provisioner "shell" {
    inline = [

    "cat > /etc/nginx/conf.d/${var.service_name}.conf <<EOF\n" +
    "  server {\n" +
    "    listen 80;\n" +
    "    server_name _;\n" +
    "\n" +
    "    # Rewrite /x/health to /health\n" +
    "    location /${var.service_name}/health {\n" +
    "      proxy_pass http://localhost/health;  # Replace 8080 with your app port\n" +
    "      proxy_set_header Host \\$host;\n" +
    "      proxy_set_header X-Real-IP \\$remote_addr;\n" +
    "    }\n" +
    "\n" +
    "    # Rewrite /x/* to /*\n" +
    "    location /${var.service_name}/ {\n" +
    "      rewrite ^/${var.service_name}/(.*) /\\$1 break;\n" +
    "      proxy_pass http://localhost:3000;  # Replace 8080 with your app port\n" +
    "      proxy_set_header Host \\$host;\n" +
    "      proxy_set_header X-Real-IP \\$remote_addr;\n" +
    "    }\n" +
    "  }\n" +
    "  EOF",
    "systemctl restart nginx"
    ]
  }
  
}