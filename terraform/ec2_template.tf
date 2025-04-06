resource "aws_launch_template" "worker-template" {
  name = "worker-template"

  instance_type = "t2.micro"
  key_name      = "test"

  image_id = var.worker_ami

  vpc_security_group_ids = [aws_security_group.private_sg.id]


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


resource "aws_launch_template" "vote-template" {
  name = "vote-template"

  instance_type = "t2.micro"
  key_name      = "test"

  image_id = var.vote_ami

  vpc_security_group_ids = [aws_security_group.private_sg.id]


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


resource "aws_launch_template" "result-template" {
  name = "result-template"

  instance_type = "t2.micro"
  key_name      = "test"

  image_id = var.result_ami

  vpc_security_group_ids = [aws_security_group.private_sg.id]


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