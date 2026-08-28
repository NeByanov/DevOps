resource "docker_network" "tofu_lab" {
  name   = "tofu-lab"
  driver = "bridge"
}

resource "docker_image" "nginx" {
  name = var.nginx
}

resource "docker_container" "tofu_lab_web" {
  name  = "tofu-lab-web"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.tofu_lab.name
  }

  ports {
    internal = 80
    external = var.web_port
    ip       = "127.0.0.1"
  }

  labels {
    label = "managed-by"
    value = "opentofu"
  }

  labels {
    label = "environment"
    value = "lab"
  }

  labels {
    label = "project"
    value = "tofu-lab"
  }

  labels {
    label = "opentofu.managed"
    value = "true"
  }
}
