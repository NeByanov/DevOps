variable "nginx" {
  description = "Docker-образ Nginx"
  type        = string
  default     = "nginx:1.31.4"
  
  labels = {
    lab-label = "check-plan-apply"
  }
}

variable "web_port" {
  description = "127.0.0.1 "
  type        = number
  default     = 8888
}
