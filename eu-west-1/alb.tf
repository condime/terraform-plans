resource "aws_lb" "mastodon" {
  name = "mastodon"

  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id]
  subnets            = module.public_subnets.subnet_ids

  tags = {
    Name = "mastodon"
  }
}

resource "aws_lb_target_group" "mastodon-web" {
  name        = "mastodon-web"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    interval = 10
    matcher  = "200"
    path     = "/health"
    port     = "traffic-port"
    protocol = "HTTP"
    timeout  = 5

    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "mastodon-streaming" {
  name        = "mastodon-streaming"
  port        = 4000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    interval = 10
    matcher  = "200"
    path     = "/api/v1/streaming/health"
    port     = "traffic-port"
    protocol = "HTTP"
    timeout  = 5

    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
