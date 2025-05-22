variable "project" { type = string }
variable "project_id" { type = string }
variable "region" { type = string }
variable "environment" { type = string }
variable "availability_zones" { type = list(string) }
variable "vpc_cidr" { type = string }
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }
