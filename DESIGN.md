# Architecture Design Document

This document describes the architecture design, patterns, and structural organization of the `homelab` monorepo. It serves as reference for understanding how subsystems relate to each other, deployment workflows, and infrastructure interactions.

## System Overview

### Infrastructure Stack Layers

```
┌─────────────────────────────────────────────┐
│  Physical Layer (Baremetal)                │
│  ──────────────────                        │
│  • Dell T630 Tower                         │
│    • Bare Proxmox Hypervisor               │
│                                            │
│  • tethys baremetal host:                  │
│    • Intel Core i7 7700k, 32GB RAM        │
│    • NVIDIA RTX2080Ti 11GB GPU for inference
│                                            │
└─────────────────────────────────────────────┘
              ▼
┌─────────────────────────────────────────────┐
│  Orchestration Layer (Terraform + Ansible)  │
│  ──────────────────                        │
│  • `/base/builds/*/` - Subsystem modules   │
│    • Terraform state files                 │
│    • Provisioning scripts                  │
│                                            │
└─────────────────────────────────────────────┘
              ▼
┌─────────────────────────────────────────────┐
│  Kubernetes Layer (Regulus Cluster)        │
│  ──────────────────                        │
│  • ArgoCD clusters                         │
│    • `/base/builds/regulus/argocd/`        │
│                                        │
└─────────────────────────────────────────────┘
              ▼
┌─────────────────────────────────────────────┐
│  Application Layer (Workloads)             │
│  ──────────────────                        │
│  • NAS, Gaming, Router                     │
│  • Workload patterns:                      │
│    - Kubernetes on baremetal T630          │
│    - VMware/Proxmox VMs in Proxmox         │
│  • LLM Stack (Hermes/Ollama, Whisper-Kokoro) │
│  • Video Processing (FFmpeg+RTMP)          │
└─────────────────────────────────────────────┘
```

## Repository Structure Deep Dive

### Primary Organization Pointers
| Directory | Purpose | Example Use Case |
|-----------|---------|------------------|
| `base/builds/` | Main workload modules | Deploy new service |
| `doc/` | Project-wide docs, analysis | Performance reviews |
| `.github/workflows/` | GitHub Actions automation | CI/CD pipelines |

### /base/builds/ Subsystem Categories

#### Core Infrastructure (Priority 1)
```bash
~/Dev/homelab/base/builds/regulus/
├── argocd/projects/monitoring/   # Monitoring stack deployment
│   └── ArgoCD app templates
├── terraform.tfvars              # Cluster infrastructure vars
└── .github/workflows/            # Regulus-specific automation
```

**Purpose**: A Kubernetes cluster running most actual homelab workloads (monitoring, LLM stack, user apps). Note: Regulus is **not** core infrastructure itself - it's simply the workspace where workloads run.

#### LLM Inference Projects (Priority 2)
All projects under `tethys/docker/*` are valid LLM inference providers and supporting tools:
- **Hermes Agent**: AI agent work environment
- **Ollama-whisper-kokoro**: Active inference provider on Tethys
```bash
~/Dev/homelab/base/builds/tethys/docker/
├── vllm/           # LLM inference stack
│   └── llama.cpp models  # Local inference deployments
├── [other tools...]      # Supporting inference utilities
```

**Purpose**: Hermes agent, Whisper AI, Kokoro TTS - local LLM infrastructure
**Dependencies**: Requires CPU (Qwen/Qwen-VL), memory (GGUF quantization)

#### Virtualization & User Workloads (Priority 3-6)
```bash
~/Dev/homelab/base/builds/
├── nas/                          # Network-attached storage, ZFS
├── homelab-router/               # Router infrastructure
├── gamededi/                     # Gaming deployment environment
└── [future subsystems...]        # Additional workloads
```

## Data Flow & Interactions

### 1. GitOps Deployment Pattern

```
Developer/Agent         ArgoCD          Kubernetes (Regulus)
    │                      │                    │
    ├─> Commit to branch  ─┤                  │
    │   in repo           ─┤                  │
    │                      ├──────────────────►│
    │                      │    Sync triggered │
    │                      │          by ArgoCD│
    │                      │            Hook    │
    │                      └───────────────────┘
```

**Flow**:
1. Agent commits changes to `~/Dev/homelab/`
2. PR merged to main triggers `.github/workflows/deploy.yaml`
3. ArgoCD detects repository change
4. App templates applied to Regulus cluster

### 2. External Secret Flow (Recommended Pattern)

```
┌─────────────┐          ┌──────────────────┐        ┌─────────────┐
│   Agent     │          │  GitHub Secrets  │        │  Vault      │
│  Writes Env │          │  (.github)       │   ◄──►  │ (External)  │
│    Files    │          └──────────────────┘        └────▲────────┘
├─────────────┤                                           │
│ tfvars w/   ├─────────────────► ArgoCD/Cluster         │
│ External    │               Reference secrets in       │
│ Secret Refs  │                                          │
│  $vault.XXX ◄──┼──────────────────► Terraform State    │
└─────────────┘                                          │
                                                          └───────┘
```

**Pattern**: Avoid committing real secrets. Use:
- GitHub Actions secrets for CI/CD
- External Secrets Operator in cluster (referenced from Argo)
- Environment variables pointing to vault

### 3. Testing Flow (Before Production Deploy)

```bash
# Recommended validation sequence:
1. Create feature branch   → git checkout -b feat/mycomponent/task
2. Local Docker testing    → Test isolated environment
3. GitHub PR review        • Code review + workflow check
4. Merged to main          ◄── Triggers deploy automation
5. Validation in cluster   ArgoCD applies changes
6. Verification logs       Check cluster state
```

## Component Communication Contracts

### Terraform External Secrets Reference Format
```hcl
# ~/.Dev/homelab/base/builds/<subsystem>/terraform.tfvars.example
external_secrets_config = {
  PROXMOX_AUTH_TOKEN     = var.external_secret.proxmox_auth.value  # Reference vault
  AWS_ACCESS_KEY_ID      = aws.access_key_id                       # Cloud creds
}
```

### Argo CD App Template Pattern
Each Argo app follows this pattern:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>-regulus
spec:
  project: regulus
  source:
    repoURL: https://github.com/tkjode/homelab.git
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  # References external secrets via External Secrets Operator if available
```

## Infrastructure Patterns by Subsystem Type

### Kubernetes Cluster (Regulus)
- **Scale Strategy**: Horizontal pod autoscaler, multi-replica deployment strategies
- **Security Boundaries**: Namespace isolation, RBAC controls, network policies
- **GitOps Integration**: ArgoCD application templates as deployment units

### NAS/Storage
- **Persistence Model**: ZFS pools with mirroring
- **Backup Integration**: Offloading for redundancy (external storage)
- **Network Exposure**: Internal-only or reverse proxied via haproxy ingress

### LLM Inference Stack
- **Resource Pattern**: CPU-focused (gguf), OOM-safe memory limits
- **Model Management**: Local storage with versioning strategy
- **Deployment Scaling**: Single-instance initially, multi-replica for high load

## Deployment Workflow Patterns
```bash
/home/tkjode/Dev/homelab/base/builds/<subsystem>/
├── terraform.tfvars          # Variable overrides (non-secret)  
└── scripts/                  # Deployment/validation utilities 
    └── README.md             # Subsystem-specific guidance
```
# Repo Root Workflows Pattern

# Example structure:
ArgoCD App Components:
  ├─ Monitoring       (alerts, exporters)
  ├─ Hometheater      (media services)
  └─ [component-name]s ... (individual subsystems)

Deployment Options:
A. Individual app updates → Independent rollbacks possible
B. Combined all-at-once   │→ Faster but riskier

Recommendation:
- Critical systems use strategy A (single rollout)
- Non-critical can batch (strategy B)
```

## Common Implementation Templates

### New Subsystem Template Structure

For adding new workloads, follow this pattern in `/base/builds/`:

```bash
~/Dev/homelab/base/builds/<new-subsystem>/
├── terraform.tfvars          # Local overrides (no secrets!)
├── .github/workflows/        <!-- CI/CD automation
│   └─ deploy.yml            → Must integrate with main workflow chain
├── scripts/
│   ├── validate.sh          # Pre-flight checks before deployment
│   └─ cleanup.sh            # Rollback utilities if needed
└── README.md                 <!-- Document: what, why, how for humans -->
```

### External Secret Management Template

**BAD** - Commit secrets to repo:
```bash
git add terraform.tfvars  # DON'T DO THIS! Would commit PROXMOX_TOKEN directly
```

**GOOD** - Reference external vaults:
```hcl
# terraform.tfvars (reference only):
external = {
  token_ref = "${var.secrets.proxmox_token.token_secret}"
}

# Secrets kept external:
• GitHub Actions environment secrets for testing pipeline
• External Secrets Operator in cluster for runtime operations
• Locally: tfenv with separate non-git keyring storage
```

## Monitoring & Observability Integration

All components should integrate with the monitoring subsystem under `/base/builds/regulus/argocd/projects/monitoring`. Consider:

**Collectors**:
- Prometheus exporters per component
- Grafana dashboards (defined via Helm charts or Terraform)

**Alert Rules**:
- Follow existing patterns in `~/Dev/homelab/doc/performance/` directory
- Alert routing through monitoring cluster
- Email/SMS integration for critical issues

## Scaling Architecture Considerations

### Component Scaling Patterns by Type

| Category     | Horizontal | Vertical | Notes                    |
|--------------|------------|----------|---------------------------|
| Web Apps     | ✅ Primary  | Never    | Use HPA + Argo sync       |
| Database     | ❌ No       │✅ Yaws    │ Single instance, scaled resources |
| NAS          | ❌ No      │ Scale NFS │ Shared resources only   |
| LLMs         | ⚠️ Special  ✅ Multi-GPU│ Quantization helps scale |

### Memory & Resource Budgeting

**Critical Resources (Per Subsystem Allocation)**:
- **Regulus Cluster**: Dedicated memory pool, CPU isolation
- **LLM Inference**: Separate GPU/CPU cores if available
- **NAS/Storage**: Disk IOPS budget, network bandwidth allocation

## Error Handling & Failure Recovery

### Proxmox API Rate Limits

**Problem**: Rate limits cause test failures when running from same IP repeatedly.

**Mitigation Strategy**:
```bash
# DO THIS: Add token expiration checks in deployment scripts
tfenv state pull --format=json  # Validate before push

# DON'T: Run too many tests in quick succession
# Every rate-limited API call blocks other calls temporarily

# Rate limit tracking in doc/performance/ for documentation
```

### Rollback Strategy Per Subsystem

1. ArgoCD manages rollback at app level (`.spec.rollback.enabled=true`)
2. Terraform state can be rolled back to previous commits
3. Critical subsystems need explicit validation before applying changes

## Version & Branch Strategy Recommendations

| Component | Branch Pattern      | Recommended Workflow     |
|-----------|---------------------|--------------------------|
| Core infra (regulus/monitoring) | `main` → feature | Strict approval gates   |
| LLM stack  │ Per model/service   │ Separate branches for isolation |
| User apps | Feature per service│ Test locally, merge to main   |

## Security Boundaries Map

```
┌─────────────────────┐
│ 🛡️ GitHub Actions   │
│ (secrets storage)    │  ───►  ◄── External Secrets Operator
└─────────────────────┘              Accesses runtime secrets

            ▼
┌─────────────────────┐
│ 🛡️ Cluster Layer     │   Namespace isolation, RBAC limits
└─────────────────────┘

            ▼
┌───────────────────────────┐
│ 🛡️ Workload Resources    │  Internal-only or reverse proxied
└───────────────────────────┘

External Traffic Flow:
Internet → Gateway (haproxy) → Ingress (Envoy/Kong) → Apps (namespaced, protected)
```

## Checklist for Design Review Before Merging

Before merging any architecture changes:

1. ✅ Does this follow the documented component structure in `/base/builds/`?
2. ✅ Are secrets handled via external references (no plaintext commits)?
3. ✅ Is testing included in `.github/workflows/` before production deployment?
4. ✅ Does integration with monitoring consider existing patterns?
5. ✅ Is rollback strategy considered/provided for this subsystem?

---

**Last Review:** 2026-08-04
**Branch:** `chore/agentic/first-run` (create-phase)
**Author**: AI Agent Assistant to User tkjode


