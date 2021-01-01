resource "digitalocean_droplet" "vault" {
  region = var.do_region
  image  = "ubuntu-18-04-x64"
  name   = "vault"
  size = "s-1vcpu-1gb"
  user_data = data.template_file.cloud_init.rendered
  monitoring = var.monitoring
  ipv6 = var.ipv6
  backups = var.backups
  private_networking = var.private_networking
}

resource "digitalocean_record" "vault_dns_a" {
  domain = var.do_domain
  type   = "A"
  name   = var.do_subdomain
  value  = digitalocean_droplet.vault.ipv4_address
  # Only creates record if do_create_record is true
  count  = var.do_create_record == true ? 1 : 0
  ttl = var.dns_ttl
}

resource "digitalocean_record" "vault_dns_aaaa" {
  domain = var.do_domain
  type   = "AAAA"
  name   = var.do_subdomain
  value  = digitalocean_droplet.vault.ipv6_address
  # Only creates record if do_create_record is true
  count  = var.do_create_record && var.ipv6 == true ? 1 : 0
  ttl    = var.dns_ttl
}
