variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "stage_name" {
  description = "Stage name (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "prsls-tf-jasper"
}
