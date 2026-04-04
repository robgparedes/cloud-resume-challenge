variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Project prefix used for naming resources"
  type        = string
  default     = "cloudresume"
}

variable "allowed_origin" {
  description = "Frontend origin used for CORS configuration"
  type        = string
  default     = "https://robertgparedes.com"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS edit permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
}

variable "frontend_origin_domain" {
  description = "S3 website endpoint for frontend"
  type        = string
}

variable "frontend_origin_id" {
  description = "CloudFront origin ID"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (must be in us-east-1)"
  type        = string
}

variable "web_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
}