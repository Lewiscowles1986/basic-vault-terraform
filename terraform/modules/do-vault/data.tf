data "local_file" "ssh_key"{
  filename = pathexpand(var.ssh_key_file)
}

data "template_file" "cloud_init" {
  template = file("${path.module}/cloud-config.tpl")
    vars = {
      ssh_key=data.local_file.ssh_key.content,
      full_domain_name="${var.do_subdomain}.${var.do_domain}"
      letsencrypt_email=var.letsencrypt_email
      do_token=var.do_token
    }
}
