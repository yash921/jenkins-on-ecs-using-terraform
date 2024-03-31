output "ecr_urls" {
  value = [for ecr in module.ecr : ecr.repository_url]
}