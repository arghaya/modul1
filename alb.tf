
module "alb" {
  source = "cloudposse/alb/aws"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  #attributes = var.attributes
  delimiter  = "-"

  vpc_id                                  = module.vpc.vpc_id
  security_group_ids                      = [module.vpc.vpc_default_security_group_id]
  subnet_ids                              = ["subnet-0ac2208bebb96572f", "subnet-0b9594d05348ab0e1"]
  internal                                = false
  http_enabled                            = true
  http_redirect                           = true
  access_logs_enabled                     = false
  cross_zone_load_balancing_enabled       = false
  http2_enabled                           = true
  idle_timeout                            = 30
  ip_address_type                         = "ipv4"
  default_target_group_enabled            = false
  deletion_protection_enabled             = true
  deregistration_delay                    = 10
  health_check_path                       = "/jenkins/"
  health_check_timeout                    = 5
  health_check_healthy_threshold          = 5
  health_check_unhealthy_threshold        = 5
  health_check_interval                   = 9
  health_check_matcher                    = "200"
  target_group_port                       = 80
  target_group_target_type                = "instance"
  #stickiness                              = "object({cookie_duration = number, enabled         = bool})"

  alb_access_logs_s3_bucket_force_destroy         = true
  alb_access_logs_s3_bucket_force_destroy_enabled = true
  target_group_name = aws_lb_target_group.lb-jenkins.name

}


resource "aws_lb_target_group" "lb-jenkins" {
  name     = "arghaya-module-lb-jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group" "lb-app" {
  name     = "arghaya-module-lb-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "lb_jenkins" {
  target_group_arn = aws_lb_target_group.lb-jenkins.arn
  target_id        = module.instance-jenkins.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "lb_app" {
  target_group_arn = aws_lb_target_group.lb-app.arn
  target_id        = module.instance-app.id
  port             = 8080
}


 resource "aws_lb_listener" "alb-listener" {
load_balancer_arn = module.alb.alb_arn
 port              = "80"
  protocol          = "HTTP"

  default_action {
  type             = "forward"
     target_group_arn = aws_lb_target_group.lb-jenkins.arn
   }
}