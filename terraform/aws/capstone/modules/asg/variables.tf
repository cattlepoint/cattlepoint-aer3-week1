variable "project" { type = string }
variable "project_id" { type = string }
variable "region" { type = string }
variable "environment" { type = string }
variable "availability_zones" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "instance_type" { type = string }
variable "instance_count_min" { type = number }
variable "instance_count_max" { type = number }
variable "instance_count_desired" { type = number }
variable "main_alb_tg_arn" { type = string }
variable "allow_http" { type = list(string) }
