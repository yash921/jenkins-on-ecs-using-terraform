module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.app_name}-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = var.cloud_watch_log_group_name
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    jenkins-controller = {
      enable_autoscaling = false
      cpu                       = 4096
      memory                    = 16384
      create_task_exec_iam_role = false
      task_exec_iam_role_arn    = aws_iam_role.task_exec_role.arn
      create_tasks_iam_role     = false
      tasks_iam_role_arn        = aws_iam_role.task_role.arn

      volume = {
        "jenkins-controller-volume" = {
          efs_volume_configuration = {
            file_system_id     = module.efs.id
            transit_encryption = "ENABLED"
            authorization_config = {
              access_point_id = module.efs.access_points["jenkins_ecs"].id
              iam             = "ENABLED"
            }
          }
        }
        "jenkins-temp-volume" = {
          efs_volume_configuration = {
            file_system_id     = module.efs.id
            transit_encryption = "ENABLED"
            authorization_config = {
              access_point_id = module.efs.access_points["jenkins_ecs_temp"].id
              iam             = "ENABLED"
            }
          }
        }

      }

      enable_execute_command = true
      container_definitions = {
        # fluent-bit = {
        #   cpu       = 512
        #   memory    = 1024
        #   essential = true
        #   image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
        #   firelens_configuration = {
        #     type = "fluentbit"
        #   }
        #   memory_reservation = 50
        # }

        jenkins-controller = {
          cpu       = 2048
          memory    = 8192
          essential = true
          image     = data.aws_ecr_image.jenkins_controller_image.image_uri
          port_mappings = [
            {
              name          = "jenkins-controller"
              containerPort = local.jenkins_container_port
              protocol      = "tcp"
            }
          ]
          mount_points = [
            {
              containerPath = "/var/jenkins_home",
              sourceVolume  = "jenkins-controller-volume"
            },
            {
              containerPath = "/tmp",
              sourceVolume  = "jenkins-temp-volume"
            }
          ]
          # dependencies = [{
          #   containerName = "fluent-bit"
          #   condition     = "START"
          # }]
          enable_cloudwatch_logging = true
        #   log_configuration = {
        #     logDriver = "awsfirelens"
        #     options = {
        #       Name                    = "jenkins-controller"
        #       region                  = var.region
        #       delivery_stream         = "jenkins-controller-stream"
        #       log-driver-buffer-limit = "2097152"
        #     }
        #   }
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["jenkins_ecs"].arn
          container_name   = "jenkins-controller"
          container_port   = local.jenkins_container_port
        }
      }

      subnet_ids = local.private_subnet_ids
      security_group_rules = {
        "alb_ingress_${local.jenkins_container_port}" = {
          type                     = "ingress"
          from_port                = local.jenkins_container_port
          to_port                  = local.jenkins_container_port
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}