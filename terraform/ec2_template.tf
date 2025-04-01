resource "aws_launch_template" "template" {
  name = "worker"

  instance_type = "t2.micro"
  key_name     = "test"

  image_id = var.worker_ami

  vpc_security_group_ids = [aws_security_group.public_sg.id]

    
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  update_default_version = true


  lifecycle {
    create_before_destroy = true
  }
  
}