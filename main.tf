terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }

  backend "local" {}
}

locals {
  configuration = yamldecode(file("./configuration.yaml"))
}

resource "hcloud_ssh_key" "main" {
  for_each = local.configuration.keys
  name       = each.key
  public_key = each.value
}

resource "hcloud_server" "main" {
  name        = "devbox"
  image       = "ubuntu-24.04"
  server_type = local.configuration.server_type
  location = local.configuration.location
  ssh_keys = [for k in hcloud_ssh_key.main : k.id]
  keep_disk = false
  lifecycle {
    ignore_changes = [ssh_keys]
  }
}

output public_ip {
  value       = {
    ipv4 = hcloud_server.main.ipv4_address
    ipv6 = hcloud_server.main.ipv6_address
  }
  sensitive   = false
  description = "The IPv4 on the public internet"
}
