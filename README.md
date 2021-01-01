# HashiCorp Vault DigitalOcean Terraform

## Pre-requisites

* Install terraform
* Sign up to DigitalOcean
* Install git
* Ensure your DNS nameservers for the domain in question are held by digitalocean

> **NOTE:** Yes that really should be all you need

## Steps

1. `git clone https://github.com/Lewiscowles1986/basic-vault-digitalocean-terraform.git`
2. `cd basic-vault-digitalocean-terraform/terraform/components/bootstrap`
3. `terraform init`
4. `terraform plan` (you will be asked for variables, you can supply them using a tfvars file, but it's out of scope here)
5. `terraform apply` (see prior point for note about variables)

## Management

This example contains a basic certbot rotation for certificates.
They *SHOULD NOT* expire and *SHOULD NOT* need to be renewed. No warranty or representation of merchantability is provided.

It was part of setting up a minimum viable Vault on DigitalOcean and likely should not be used in production

## Notes / Future-work

* Setup digitalocean loadbalancer, tell it to get the certs
* Setup do consul as part of this and configure vault to use it for cross-data-center secrets
* It would be trivially simple to move the certbot to your local machine and distribute with terraform / cloud-init.
* Reduce boot times or work out "ready-state" so this can be blue-green deployed without downtime
* Sometimes Cloud-init does not run all the steps I have asked it to run. I Personally find this incredibly frustrating
  * if one or more parts of this do not complete `service vault status` should give a useful error message.

## Thanks

To letsencrypt and certbot teams. Hashicorp & DigitalOcean, and my wife, who puts up with the incessant tinkering.
