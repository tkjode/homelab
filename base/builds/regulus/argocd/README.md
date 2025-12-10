# K8S Manifests

## Usage

At cluster bootstrap time, the installed ArgoCD instance will be configured with an initial set of Applications.

1. ArgoCD will matrix over the `day0-argo-manifests` folder and...
1. Install all Kustomize based manifests to the cluster.
1. Finally ArgoCD will matrix over the `day1-app-of-apps` folder and..
1. Create App matrix subscriptions to the appropriate repositories.

## Critical Bits

- Secrets for each repository need to be seeded.
- Preference for homelab is to use a runner `Environment` entry that provides a trusted SSH key
- Secret must be placed into the `argocd` namespace and follow the repo/secret mapping used by Argo (labels/annotations)
