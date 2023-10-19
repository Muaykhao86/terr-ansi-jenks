resource "aws_lb" "application-lb" {
  provider           = aws.region-master
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tags = {
    Name = "jenkins-lb"
  }
}

resource "aws_lb_target_group" "app-lb-tg" {
  provider = aws.region-master
  name     = "app-lb-tg"
  port     = 80
  vpc_id   = aws_vpc.vpc_master.id
  protocol = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = 80
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    Name = "jenkins-tg"
  }
}

resource "aws_lb_listener" "jenkins-lb-listener-http" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.application-lb.arn
  port              = var.webserver-port
  protocol          = "HTTP"
  default_action {
    # target_group_arn = aws_lb_target_group.app-lb-tg.arn
    # type             = "forward"
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301" // 301 = permanent redirect
    }
  }
}

resource "aws_lb_listener" "jenkins-lb-listener-https" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.application-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.jenkins-lb-https.arn
  default_action {
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "jenkins-lb-tg-attachment" {
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = aws_instance.jenkins-master.id
  port             = 80
}