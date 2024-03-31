variable "region" {
  type        = string
  description = "Region where to deploy resources to"
  default     = "ap-south-1"
}

variable "app_name" {
  type        = string
  description = "Name of the app"
  default     = "Jenkins"
}


variable "profile" {
  type        = string
  description = "Name of the aws profile to use to deploy"
}

variable "ecr_repos" {
  type        = list(string)
  description = "Name of the ecr repos"
  default     = []
}
