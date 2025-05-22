variable "project" {
  description = "Project name"
  type        = string
  default     = "Null project name"
}

variable "project_id" {
  description = "AWS Project ID"
  type        = string
  default     = "nullprojectid"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, stage, prod)"
  type        = string
  default     = "null"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
variable "instance_count_min" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 3
}
variable "instance_count_max" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 6
}

variable "instance_count_desired" {
  description = "Desired number of EC2 instances desired"
  type        = number
  default     = 3
}
