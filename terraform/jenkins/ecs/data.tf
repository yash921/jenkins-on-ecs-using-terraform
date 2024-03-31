data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.app_name]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.app_name}-private-*"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.app_name}-public-*"]
  }
}

data "aws_ssm_parameter" "fluentbit" {
  name = "/aws/service/aws-for-fluent-bit/stable"
}

data "aws_subnet" "private_subnets" {
  for_each = toset(data.aws_subnets.private_subnets.ids)
  id       = each.value
}

data "aws_ecr_image" "jenkins_controller_image" {
  repository_name = "jenkins-controller"
  most_recent     = true
}