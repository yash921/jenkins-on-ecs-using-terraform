data "aws_caller_identity" "current" {}

module "ecr" {
  for_each                          = toset(var.ecr_repos)
  source                            = "terraform-aws-modules/ecr/aws"
  repository_name                   = each.value
  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}