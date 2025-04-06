resource "aws_autoscaling_group" "worker" {
  name             = "worker-asg"
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  vpc_zone_identifier = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "private"
  ]

  launch_template {
    id      = aws_launch_template.worker-template.id
    version = aws_launch_template.worker-template.latest_version
  }


  # Automatically trigger instance refresh when the launch template changes
  instance_refresh {
    strategy = "Rolling" # Replace instances in batches
  }

  # Attach the ASG to the target group
  target_group_arns = [aws_lb_target_group.worker.arn]


  

}
resource "aws_autoscaling_group" "vote" {
  name             = "vote-asg"
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  vpc_zone_identifier = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "private"
  ]

  launch_template {
    id      = aws_launch_template.vote-template.id
    version = aws_launch_template.vote-template.latest_version
  }


  # Automatically trigger instance refresh when the launch template changes
  instance_refresh {
    strategy = "Rolling" # Replace instances in batches
  }

  # Attach the ASG to the target group
  target_group_arns = [aws_lb_target_group.vote.arn]
}


resource "aws_autoscaling_group" "result" {
  name             = "result-asg"
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  vpc_zone_identifier = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "private"
  ]

  launch_template {
    id      = aws_launch_template.result-template.id
    version = aws_launch_template.result-template.latest_version
  }


  # Automatically trigger instance refresh when the launch template changes
  instance_refresh {
    strategy = "Rolling" # Replace instances in batches
  }

  # Attach the ASG to the target group
  target_group_arns = [aws_lb_target_group.result.arn]

}

