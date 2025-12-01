# Cluster HAProxy Front-End Certificates
# --------------------------------------
# This will just be for testing PKI on HAProxy
# Will need to support LetsEncrypt CertBot later

resource "tls_private_key" "apps-proxy-master" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "proxy-authority" {
  private_key_pem     = tls_private_key.apps-proxy-master.private_key_pem
  validity_period_hours = 87600
  is_ca_certificate   = true
  allowed_uses    = [ "digital_signature", "cert_signing", "key_encipherment", "crl_signing" ]

  dns_names       = ["ca.apps.phalnet.com"]

  subject {
    common_name   = "ca.apps.phalnet.com"
    organization  = "PhalNet Inc. HomeLabs"
  }
}

# HAProxy CSR/CRT/KEY for tcp/443

resource "tls_cert_request" "req-apps-phalnet-com" {
  private_key_pem = tls_private_key.apps-proxy-master.private_key_pem
  dns_names       = [ "apps.phalnet.com", "*.apps.phalnet.com" ]
  ip_addresses    = [ "10.0.0.10", "192.168.64.1" ]

  subject {
    common_name   = "apps.phalnet.com"
    organization  = "PhalNet Labs HAProxy"
    organizational_unit = "Regulus"
  }
}

resource "tls_locally_signed_cert" "cert-apps-phalnet-com" {
  ca_private_key_pem = tls_private_key.apps-proxy-master.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.proxy-authority.cert_pem
  cert_request_pem   = tls_cert_request.req-apps-phalnet-com.cert_request_pem

  allowed_uses      = [ "digital_signature", "key_encipherment", "data_encipherment" ]
  validity_period_hours = 87600
}

