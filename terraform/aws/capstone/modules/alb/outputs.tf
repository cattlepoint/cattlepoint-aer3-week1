output "main_alb_dns_name" { value = aws_lb.main_alb.dns_name }
output "main_alb_tg_arn" { value = aws_lb_target_group.main_alb_tg.arn }
