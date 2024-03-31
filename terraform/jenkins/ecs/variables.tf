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

variable "cloud_watch_log_group_name" {
  type        = string
  description = "Name of the cloudwatch to create for ecs"
  default     = "/ecs/jenkins-controller-logs"
}

variable "profile" {
  type        = string
  description = "Name of the aws profile to use to deploy"
}