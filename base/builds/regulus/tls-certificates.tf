resource "tls_private_key" "ingress-private-key" {
  algorithm = "ECDSA"
}

resource "tls_private_key" "k8s-api-private-key" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "ingress-certificate" {
  private_key_pem = tls_private_key.ingress-private-key.private_key_pem

  validity_period_hours = 8760

  subject {
    common_name = "ingress.apps.phalnet.com"
    organization = "PhalNet Inc."
    organizational_unit = "HomeLabs"
    email_address = "jody.reid@phalnet.com"
    street_address = ["23 Ypres Rd."]
    locality    = "York"
    province    = "ON"
    country     = "CA"
    postal_code = "M6M 0B2"
  }

  dns_names = [ "*.apps.phalnet.com", "apps.phalnet.com" ]
  ip_addresses = [ "10.0.0.10", "192.168.64.1" ]
  allowed_uses = [ "key_encipherment", "digital_signature", "server_auth" ]
}

resource "tls_self_signed_cert" "k8s-api-certificate" {
  private_key_pem = tls_private_key.k8s-api-private-key.private_key_pem

  validity_period_hours = 8760

  subject {
    common_name = "api.regulus.phalnet.com"
    organization = "PhalNet Inc."
    organizational_unit = "HomeLabs"
    email_address = "jody.reid@phalnet.com"
    street_address = ["23 Ypres Rd."]
    locality    = "York"
    province    = "ON"
    country     = "CA"
    postal_code = "M6M 0B2"
  }

  dns_names = [ "api.regulus.phalnet.com" ]
  ip_addresses = [ "10.0.0.10", "192.168.64.1" ]
  allowed_uses = [ "key_encipherment", "digital_signature", "server_auth" ]
}