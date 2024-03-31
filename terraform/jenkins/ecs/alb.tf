module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = "${var.app_name}-alb"

  load_balancer_type = "application"

  vpc_id  = local.vpc_id
  subnets = local.public_subnet_ids

  enable_deletion_protection = true

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    jenkins = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "jenkins_ecs"
      }
    }
  }

  target_groups = {
    jenkins_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.jenkins_container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/login?from=%2F"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
      create_attachment = false
    }
  }
}