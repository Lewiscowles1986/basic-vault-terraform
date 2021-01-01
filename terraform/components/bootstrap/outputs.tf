output "droplet_ip" {
  value = module.digitalocean_basic_vault.droplet_ip
}

output "droplet_ipv6" {
  value = module.digitalocean_basic_vault.droplet_ipv6
}

output "gateway_url" {
  value = module.digitalocean_basic_vault.gateway_url
}
