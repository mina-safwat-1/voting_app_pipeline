resource "aws_lb_target_group" "worker" {
  name        = "worker-tg"
  port        = 80  # Port your instances listen on (e.g., HTTP)
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id  # Replace with your VPC ID if needed
  target_type = "instance"       # Direct traffic to EC2 instances

  health_check {
    path                = "/worker"     # Health check endpoint
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }
}


resource "aws_lb_target_group" "voting" {
  name        = "voting-tg"
  port        = 80  # Port your instances listen on (e.g., HTTP)
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id  # Replace with your VPC ID if needed
  target_type = "instance"       # Direct traffic to EC2 instances

  health_check {
    path                = "/voting"     # Health check endpoint
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }
}


resource "aws_lb_target_group" "result" {
  name        = "result-tg"
  port        = 80  # Port your instances listen on (e.g., HTTP)
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id  # Replace with your VPC ID if needed
  target_type = "instance"       # Direct traffic to EC2 instances

  health_check {
    path                = "/result"     # Health check endpoint
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }
}