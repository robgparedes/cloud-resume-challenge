variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Project prefix"
  type        = string
  default     = "cloudresume"
}

variable "allowed_origin" {
  description = "Frontend origin for CORS"
  type        = string
  default     = "https://robertgparedes.com"
}