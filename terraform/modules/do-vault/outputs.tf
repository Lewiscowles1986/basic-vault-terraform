output "droplet_ip" {
  value = digitalocean_droplet.vault.ipv4_address
}

output "droplet_ipv6" {
  value = digitalocean_droplet.vault.ipv6_address
}

output "gateway_url" {
  value = "https://${var.do_subdomain}.${var.do_domain}/"
}