# Cluster HAProxy Front-End Certificates
# --------------------------------------
# This will just be for testing PKI on HAProxy
# Will need to support LetsEncrypt CertBot later

resource "tls_private_key" "apps-proxy-master" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_self_signed_cert" "proxy-authority" {
  private_key_pem     = tls_private_key.apps-proxy-master.private_key_pem
  validity_period_hours = 87600
  is_ca_certificate   = true
  allowed_uses    = [ "digital_signature", "cert_signing", "key_encipherment", "crl_signing" ]

  dns_names       = [ join(".", ["ca", var.cluster-name, var.cluster-domain ]) ]

  subject {
    common_name   = join(".", ["ca", var.cluster-name, var.cluster-domain ])
    organization  = "PhalNet Inc. HomeLabs"
    organizational_unit = "Certificate Authority"
  }
}

# HAProxy CSR/CRT/KEY for tcp/443

resource "tls_cert_request" "req-apps-phalnet-com" {
  private_key_pem = tls_private_key.apps-proxy-master.private_key_pem
  dns_names       = [ join(".", [ var.cluster-name, var.cluster-domain ]), join(".", ["*", var.cluster-name, var.cluster-domain]) ]
  #ip_addresses    = [ "10.0.0.10", "192.168.64.1" ]

  ip_addresses    = [
                      cidrhost( join("/", [ var.gw-net-home.network, var.gw-net-home.mask]), var.gw-net-home.cidr ),
                      cidrhost( join("/", [ var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.gw-net-cluster.cidr )
                    ]  

  subject {
    common_name   = join(".", [ var.cluster-name, var.cluster-domain ])
    organization  = "PhalNet Labs Inc. HomeLabs"
    organizational_unit = join(" ", ["HAProxy for ", var.cluster-name])
  }
}

resource "tls_locally_signed_cert" "cert-apps-phalnet-com" {
  ca_private_key_pem = tls_private_key.apps-proxy-master.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.proxy-authority.cert_pem
  cert_request_pem   = tls_cert_request.req-apps-phalnet-com.cert_request_pem

  allowed_uses      = [ "digital_signature", "key_encipherment", "data_encipherment" ]
  validity_period_hours = 87600
}

# ---------------------------------------------
# ClusterIssuer CA for Internally Signed Certs 
# ---------------------------------------------
# 
# This CA will be injected on initialization to
# give cert-manager an Internal CA that Envoy
# and other TLSBackends can leverage to trust

resource "tls_private_key" "labs-ca" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_self_signed_cert" "labs-ca" {
  private_key_pem     = tls_private_key.labs-ca.private_key_pem
  validity_period_hours = 87600
  is_ca_certificate   = true
  allowed_uses    = [ "digital_signature", "cert_signing", "key_encipherment", "crl_signing" ]

  dns_names       = [ join(".", [var.cluster-name, "internal"]) ]

  subject {
    common_name   = join(".", [var.cluster-name, "internal"])
    organization  = "HomeLab Internal TLS Backend Signatory"
  }
}