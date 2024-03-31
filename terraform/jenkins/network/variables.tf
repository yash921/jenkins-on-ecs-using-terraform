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

variable "availability_zones" {
  type        = list(string)
  description = "List of azs"
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_cidr" {
  type        = string
  description = "Vpc cidr"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet cidrs"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet cidrs"
}

variable "profile" {
  type        = string
  description = "Name of the aws profile to use to deploy"
}