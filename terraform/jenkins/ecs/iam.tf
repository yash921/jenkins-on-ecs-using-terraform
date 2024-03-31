data "aws_iam_policy_document" "task_exec_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com","ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_exec_role_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRead",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:DescribeFileSystems"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "task_exec_role" {
  name               = "${var.app_name}-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.task_exec_assume_role_policy.json
  inline_policy {
    name   = "${var.app_name}-task-exec-policy"
    policy = data.aws_iam_policy_document.task_exec_role_policy.json
  }
}


data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# https://plugins.jenkins.io/ec2/#plugin-content-iam-setup
data "aws_iam_policy_document" "task_role_policy" {
  statement {
    actions = [
      "ec2:DescribeSpotInstanceRequests",
      "ec2:CancelSpotInstanceRequests",
      "ec2:GetConsoleOutput",
      "ec2:RequestSpotInstances",
      "ec2:RunInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeRegions",
      "ec2:DescribeImages",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "iam:ListInstanceProfilesForRole",
      "iam:PassRole",
      "ec2:GetPasswordData"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "task_role" {
  name               = "${var.app_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
  inline_policy {
    name   = "${var.app_name}-task-policy"
    policy = data.aws_iam_policy_document.task_role_policy.json
  }
}


