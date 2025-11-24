# Regulus Certificate Authority
# -----------------------------
# This can be placed onto machines cert-stores for system-wide trust
# This will be used to sign CSRs for all kubernetes components requiring a crt and key

resource "tls_private_key" "regulus-master-key" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "cluster-authority" {
  private_key_pem           = tls_private_key.regulus-master-key.private_key_pem
  validity_period_hours     = 87600
  is_ca_certificate         = true
  allowed_uses              = [ "digital_signature", "cert_signing", "key_encipherment", "crl_signing" ]
  dns_names                 = ["kubernetes"]

  subject {
    common_name             = join(".", ["kubernetes-ca", var.cluster-name, var.cluster-domain])
    organization            = "PhalNet Inc. HomeLabs"
  }
}

# Kubernetes Components
# ---------------------
# Kubernetes Delegate Certificate Authority (kubernetes-ca)
# etcd Certificate Authority (etcd-ca)
# Front-end Proxy service CA (kubernetes-front-proxy-ca)
# ServiceAccount Public/Private keypair (sa.pub+key)
# -------------
# kubeadm init should be able to generate all of the individual node certs so long as the CAs are placed appropriately.

## kubernetes-ca

resource "tls_private_key" "kubernetes-ca" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "tls_cert_request" "kubernetes-ca" {
  private_key_pem       = tls_private_key.kubernetes-ca.private_key_pem
  dns_names             = [ "kubernetes" ]

  subject {
    common_name         = "kubernetes"
    organization        = "Kubernetes Cluster Authority"
    organizational_unit = var.cluster-name
  }
}

resource "tls_locally_signed_cert" "kubernetes-ca" {
  # Authority
  ca_private_key_pem    = tls_private_key.regulus-master-key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.cluster-authority.cert_pem

  # CSR to Sign
  cert_request_pem      = tls_cert_request.kubernetes-ca.cert_request_pem

  allowed_uses          = [ "digital_signature", "cert_signing", "key_encipherment", "crl_signing" ]
  is_ca_certificate     = true
  validity_period_hours = 87600
}

## etcd-ca

resource "tls_private_key" "etcd-ca" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_cert_request" "etcd-ca" {
  private_key_pem       = tls_private_key.etcd-ca.private_key_pem
  dns_names             = [ "etcd-ca" ]

  subject {
    common_name         = "etcd-ca"
    organization        = "etcd Authority"
    organizational_unit = var.cluster-name
  }
}

resource "tls_locally_signed_cert" "etcd-ca" {
  ca_private_key_pem    = tls_private_key.regulus-master-key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.cluster-authority.cert_pem
  cert_request_pem      = tls_cert_request.etcd-ca.cert_pem

  allowed_uses          = [ "digital_signature", "cert_signing", "key_encipherment", "crl_signing" ]
  is_ca_certificate     = true
  validity_period_hours = 87600
}

## front-proxy-ca

resource "tls_private_key" "front-proxy-ca" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "front-proxy-ca" {
  private_key_pem       = tls_private_key.front-proxy-ca.private_key_pem
  dns_names             = [ "front-proxy-ca" ]

  subject {
    common_name         = "front-proxy-ca"
    organization        = "Kubernetes Proxy Authority"
    organizational_unit = var.cluster-name
  }
}

resource "tls_locally_signed_cert" "front-proxy-ca" {
  ca_private_key_pem    = tls_private_key.regulus-master-key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.cluster-authority.cert_pem
  cert_request_pem      = tls_cert_request.front-proxy-ca.cert_pem

  allowed_uses          = [ "digital_signature", "cert_signing", "key_encipherment", "crl_signing" ]
  is_ca_certificate     = true
  validity_period_hours = 87600
}

## ServiceAccount (sa.pub+key)

resource "tls_private_key" "sa-key" {
  algorithm = "RSA"
  rsa_bits = 4096
}