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
  ami_name      = "${var.service_name}-ami-new"
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
  inline = [<<-EOF
    sudo tee /etc/nginx/nginx.conf > /dev/null <<'NGINX_EOF'
    user nginx;
    worker_processes auto;
    error_log /var/log/nginx/error.log notice;
    pid /run/nginx.pid;
    include /usr/share/nginx/modules/*.conf;
    events {
        worker_connections 1024;
    }
    http {
        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent" "$http_x_forwarded_for"';
        access_log  /var/log/nginx/access.log  main;
        sendfile            on;
        tcp_nopush          on;
        keepalive_timeout   65;
        types_hash_max_size 4096;
        include             /etc/nginx/mime.types;
        default_type        application/octet-stream;
        include /etc/nginx/conf.d/*.conf;
        server {
            listen       80;
            server_name  _;
            root         /usr/share/nginx/html;

            # Load configuration files for the default server block.
            location /${var.service_name}/ {
                    rewrite ^/${var.service_name}(/?)(.*)$ /$2 break;
                    proxy_pass http://localhost:3000/;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
            }
            location /${var.service_name}/health {
                    proxy_pass http://localhost/health;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
            }
        }
    }
    NGINX_EOF
    EOF
  ]
}

  # install image
  provisioner "shell" {
    inline = [
      "sudo systemctl enable --now nginx",
      "sudo systemctl restart nginx",
    ]
  }
  

  }