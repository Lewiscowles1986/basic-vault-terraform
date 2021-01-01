#cloud-config
ssh_authorized_keys:
  - ${ssh_key}

groups:
  - vault
  - pki

users:
  - name: vault
    gecos: Vault secrets server
    primary_group: vault
    groups: vault, pki
    shell: /usr/sbin/nologin
    homedir: /var/lib/vault
    system: true

write_files:
- content: |
    [Unit]
    Description=a tool for managing secrets
    Documentation=https://vaultproject.io/docs/
    After=network.target
    ConditionFileNotEmpty=/etc/vault.hcl

    [Service]
    User=vault
    Group=vault
    ExecStart=/usr/local/bin/vault server -config=/etc/vault.hcl
    ExecReload=/usr/local/bin/kill --signal HUP $MAINPID
    SecureBits=keep-caps
    CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK CAP_NET_BIND_SERVICE
    AmbientCapabilities=CAP_SYSLOG CAP_IPC_LOCK CAP_NET_BIND_SERVICE
    NoNewPrivileges=yes
    KillSignal=SIGINT

    [Install]
    WantedBy=multi-user.target

  path: /etc/systemd/system/vault.service
- content: |
    dns_digitalocean_token = ${do_token}

  path: /etc/digitalocean-key
  permissions: "0600"
- content: |
    ui = true
    api_addr = "https://${full_domain_name}"

    backend "file" {
        path = "/var/lib/vault"
    }

    listener "tcp" {
        tls_disable = 0
        tls_cert_file = "/etc/letsencrypt/live/${full_domain_name}/fullchain.pem"
        tls_key_file = "/etc/letsencrypt/live/${full_domain_name}/privkey.pem"
        address = "0.0.0.0:443"
    }

  path: /etc/vault.hcl
  permissions: "0640"
- content: "certbot certonly --dns-digitalocean --dns-digitalocean-credentials /etc/digitalocean-key --dns-digitalocean-propagation-seconds 60 -d ${full_domain_name} -m ${letsencrypt_email} --agree-tos --renew-by-default && chown -R root:pki /etc/letsencrypt/archive && chown -R root:pki /etc/letsencrypt/live && chmod -R g+rx /etc/letsencrypt/archive && chmod -R g+rx /etc/letsencrypt/live"
  path: /etc/cron.monthly/certbot-renew
  permissions: "0600"

package_update: true

packages:
 - anacron
 - wget
 - unzip
 - certbot
 - python3-certbot-dns-digitalocean

runcmd:
- wget https://releases.hashicorp.com/vault/1.6.1/vault_1.6.1_linux_amd64.zip
- unzip vault_*.zip
- cp vault /usr/local/bin/
- chmod +x /usr/local/bin/vault
- chown vault:vault /usr/local/bin/vault
- setcap cap_net_bind_service,cap_ipc_lock=+ep /usr/local/bin/vault
- /sbin/sysctl -w net.ipv4.conf.all.forwarding=1
- install -o vault -g vault -m 750 -d /var/lib/vault
- echo 127.0.0.1 ${full_domain_name} | tee -a /etc/hosts
- systemctl daemon-reload
- certbot certonly --dns-digitalocean --dns-digitalocean-credentials /etc/digitalocean-key --dns-digitalocean-propagation-seconds 60 -d ${full_domain_name} -m ${letsencrypt_email} --agree-tos --renew-by-default
- chown -R root:pki /etc/letsencrypt/archive
- chown -R root:pki /etc/letsencrypt/live
- chmod -R g+rx /etc/letsencrypt/archive
- chmod -R g+rx /etc/letsencrypt/live
- chown -R vault:vault 770 /var/lib/vault
- chown -R root:vault /etc/vault.hcl
- systemctl start vault
- export VAULT_ADDR=https://${full_domain_name}
- echo "export VAULT_ADDR=https://${full_domain_name}" | tee -a /etc/profile
- vault operator init -key-shares=3 -key-threshold=2 > /etc/vault-init
