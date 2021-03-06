output "alb_dns" {
  value = module.webserver_module.module_web_alb_dns
}

output "web_lt_id" {
  value       = module.webserver_module.module_web_lt_id
  description = "the name of webserver launch template id"
}

output "web_asg_arn" {
  value       = module.webserver_module.module_web_asg_arn
  description = "webserver's asg id"
}

output "web_alb_arn" {
  value       = module.webserver_module.module_web_alb_arn
  description = "webserver's load balancer arn"
}

// output "rds_username" {
//   value = module.webserver_module.rds_username
// }

// output "rds_endpoint" {
//   value = module.webserver_module.rds_address
// }