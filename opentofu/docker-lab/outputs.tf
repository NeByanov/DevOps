
output "web_endpoint" {
  description = "Локальный адрес Nginx"
  value       = "http://127.0.0.1:${var.web_port}"
}

output "network_id" {
  description = "Идентификатор сети tofu-lab"
  value       = docker_network.tofu_lab.id
}
