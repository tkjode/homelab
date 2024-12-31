# Secrets Management

## Types

- __Github Token__: Authorizes runners to execute actions on behalf of this repository.
- __SSH Identity__: Authorizes ArgoCD to pull repository data down for deployments and configs, also may authorize Ansible to remote into machines for installs/maintenance.
- __Kubernetes Admin Credentials__: Allows the creation of primary Cluster Service Accounts for operator installation + initial admin user account identity which will be handled via OIDC/Keycloak.
- __AWS Route53 Service Account ARN__: Used for CertBot DNS-01 Challenges with Let's Encrypt.
- __AWS S3 Bucket for TFState ARN__: Used for storing .tfstate for all work done on Proxmox HomeLab
- __KeyCloak Realm Callback Token__: Secret generated when OIDC realm+application relationship formed