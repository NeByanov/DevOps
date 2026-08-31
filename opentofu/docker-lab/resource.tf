variable "nginx" {
  description = "Docker-образ Nginx"
  type        = string
  default     = "nginx:1.31.4"
  restart = "unless-stopped"
}

variable "web_port" {
  description = "127.0.0.1 "
  type        = number
  default     = 8888
}
