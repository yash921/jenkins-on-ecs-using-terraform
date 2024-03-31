
module "efs" {
  source                             = "terraform-aws-modules/efs/aws"
  name                               = "${var.app_name}-efs"
  encrypted                          = true
  throughput_mode                    = "elastic"
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false
  policy_statements = [
    {
      sid = "AllowAccessToJenkinsEcs"
      actions = [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientRead",
        "elasticfilesystem:DescribeMountTargets"
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = [aws_iam_role.task_exec_role.arn]
        }
      ]
    }
  ]

  mount_targets              = { for subnet in local.private_subnets : subnet.availability_zone => { subnet_id = subnet.id } }
  security_group_description = "EFS security group"
  security_group_vpc_id      = local.vpc_id
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = [for subnet in local.private_subnets : subnet.cidr_block]
    }
  }

  access_points = {
    jenkins_ecs = {
      name = "jenkins-ecs"
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/mnt/jenkins_home"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }

    jenkins_ecs_temp = {
      name = "jenkins-ecs-temp"
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/mnt/jenkins_tmp"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
  }
  enable_backup_policy = true
}