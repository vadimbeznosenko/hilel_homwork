resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group" "this" {
  name                 = "${var.name}-tg"
  port                 = var.https_protocol
  protocol             = "HTTPS"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }
}

/* resource "aws_lb_target_group_attachment" "this" {
  for_each = toset(var.instance_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.key
  port             = var.https_protocol
} */

resource "aws_lb_target_group" "ip-example" {
  name        = "ip"
  port        = var.https_protocol
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_vpc" "main" {
  cidr_block = data.aws_vpc.main.id
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn

  port     = var.https_protocol
  protocol = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "ping"
      message_body = "pong"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = ["*", "/*"]
    }
  }
}

resource "aws_lb_target_group" "ip-example" {
  name        = "ip"
  port        = var.https_protocol
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_vpc" "main" {
  cidr_block = data.aws_vpc.main.id
}
