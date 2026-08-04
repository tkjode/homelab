# Agentic Work Guide

This document describes how to perform work effectively within the `homelab` monorepo infrastructure orchestration project. It provides conventions, patterns, and guidance for human developers and AI agents working in this codebase.

## Project Location & Git Flow

### Repository Root
All effort occurs under: **`~/Dev/homelab`** (`/home/tkjode/Dev/homelab`)

### Primary Working Directory
```bash
cd ~/Dev/homelab
```

### Branch Naming Convention
Following the existing pattern in use, branch names follow this structure:
- `feat/<component>/<topic>` - New features for a subsystem  
- `fix/<component>/<issue>` - Bug fixes 
- `chore/<type>/<reason>` - Repository maintenance and git activities (types can be `agentic`, `migration`, or `release`). Example: `chore/agentic/first-run` (where you are now)

### Active Workload Areas (as of creation)
Based on current branches:
- **regulus**: Main kubernetes cluster management (monitoring/exporters, radar, prometheus)
- **tethys/docker/vllm**: LLM inference stack (hermes agent, ollama-whisper-kokoro)
- **rtmp**: Video processing and FFmpeg-based streaming

## Repository Organization

### Core Directories

#### `/base/builds/` - Primary Work Area  
Contains all infrastructure automation modules. Each directory represents a distinct subsystem or service:

```bash
/home/tkjode/Dev/homelab/base/builds/
├── nas/                    # Network Attached Storage setup
├── gamededi/               # Gaming deployment environment  
├── tethys/docker/vllm/    # Local LLM inference stack (regulus)
├── homelab-router/         # Router infrastructure
└── regulus/                # Main Kubernetes cluster
    └── argocd/projects/...  # Argo CD app templates per workload
```

#### `/doc/` - Documentation & Analysis  
Project-level documentation, analysis reports, and workstream tracking. Files like `Journal.md`, `Workstream.md`, performance analyses live here.

#### `.github/workflows/`  
GitHub Actions CI/CD pipelines that orchestrate Proxmox deployments to the baremetal compute node. **Agents should only create new workflow files when necessary**, and must understand their interconnections.

### Key Workload Patterns  

The project uses an "app of apps" pattern via Argo CD, where each workload directory in `/base/builds/` can be:
- Deployed individually for isolated testing  
- Combined as a set via main application-of-apps template

## Agent-Specific Guidelines

### 1. Working Directory Enforcement
**ALL agent work must occur in `~/Dev/homelab`**. This is codified and represents the canonical working directory for all homelab-related git operations.

### 2. Understanding Existing Workflows Before Changes  
Before modifying any workflow, review:
- How it triggers (GitHub events, paths, schedules)  
- Dependencies on other workflows  
- Required environment variables/secrets  
- Downstream impacts  

**Workflow Priority by Domain:**
1. **Regulus** - Core cluster management and monitoring
2. **Tethys/LLM stack** - Hermes/agent infrastructure  
3. **General deployments** - NAS, gaming, router workloads

### 3. Testing Before Integration  
Given the complexity of Proxmox API integrations and Argo CD orchestration:
- Not all commits require local Docker testing - ensure all changes pass basic validation in `.github/workflows` 
- Start with non-critical subsystems (separate from core regulus cluster)  
- Verify API key/secrets integration doesn't break existing pipelines

### 4. Commit & Git Conventions
**Structure commits by affected subsystem:**

```bash
git commit -m "fix(regulus:monitoring): correct prometheus scrape interval"
# NOT
git commit -m "Fixed some monitoring issues"
```

Pattern: `Type(<component>:<subsystem>): <concise description>`

### 5. Integration with Proxmox Infrastructure  
Remember the infrastructure stack layers:
- **Physical**: Dell T630 baremetal running Proxmox
- **Orchestration**: Terraform + Ansible automation (GitHub Actions triggered)
- **Kubernetes**: regulus cluster managed via Argo CD  
- **GitOps**: `/base/builds/*/` repositories sync to cluster

**Agents should only touch `/base/`, not baremetal Proxmox configuration directly.**

## Common Patterns in This Repo

### 1. Module Structure for Subsystems
```yaml
/home/tkjode/Dev/homelab/base/builds/<subsystem>/
├── README.md                # Human workflow guidance  
├── .github/                 # Workflow automation for this subsystem specifically
└── terraform.tfvars         # Terraform variable overrides (secrets excluded)
```

### 2. Argo CD Application Templates  
Each workload has corresponding App-of-Apps templates under:
`/home/tkjode/Dev/homelab/base/builds/regulus/argocd/projects/<app-name>/README.md`

### 3. Branch Workflow Pattern  
1. Create feature branch off main with descriptive name  
2. Make changes/commits to one subsystem at a time  
3. Verify local Docker testing first
4. Merge back to main (PR required for significant merges)

## Security Considerations

- **DO NOT commit secrets** to repository
- API keys, Proxmox tokens, and auth credentials must be managed separately via:  
  - GitHub Secrets in `.github/workflows` files only (no external vaults configured at this time; all sensitive data captured as GitHub Secrets)

### External Secret Storage Pattern
```bash
# DO THIS - Use external secret management
$ env | grep PROXMOX_TOKEN # from Keycloak or local vault

# DON'T commit secrets  
git add terraform.env 
# DON'T do this! Would include actual credentials!

# Instead, use these patterns:
- GitHub Actions secrets for CI/CD
- External Secrets Operator (NOT deployed) in Argo CD  
  - Referenced as $external_secret.value in Terraform
- Locally: tfenv with separate non-git keyring storage
```

## Agent-Specific Pitfalls to Avoid  

1. **Modifying `.github/workflows` without understanding dependencies** - Changing one workflow can break multiple subsystems  
2. **Assuming baremetal availability as test environment** - Test locally first in Docker where possible  
3. **Committing terraform.tfvars with secrets** - Use external secret references instead 
4. **Ignoring Proxmox API rate limits** - Tests cause this, especially on certbot rate limiting
5. **Deploying to regulus without verifying cluster state** - Can cause cascading failure  

## Available Skills & Resources

### Key Documentation Files (for agent reference)
- `~/Dev/homelab/README.md` - High-level requirements and project goals  
- `~/Dev/homelab/Journal.md` - Progress tracking and work logs 
- Subsystem READMEs in `/base/builds/*/` - Domain-specific guidance

### Common Tool Usage Patterns
```bash
# Clone operations (always from this directory):  
git clone <target> ~/Dev/homelab/<new-subdir>  # Add new subsystem  
cd /home/tkjode/Dev/homelab/base/builds/<subsystem>/     # Edit existing

# Branch operations:  
git checkout -b feat/mycomponent/task-name  

# Workflow verification:  
ls .github/workflows/  # See what exists before modifying
cat .github/workflows/deploy.yaml  # Understand triggers and actions
```

## Checklist for New Work

Before starting any agentic work on a subsystem:

1. ✅ Navigate to `/home/tkjode/Dev/homelab/base/builds/<subsystem>`
2. ✅ Read README.md in that subsection (if exists)  
3. ✅ Check related `.github/workflows/` for automation patterns  
4. ✅ Review parent Regulus project docs (`~/Dev/homelab/Journal.md`)  
5. ✅ Verify branch naming follows convention before commits  
6. ✅ Plan testing strategy - Docker vs baremetal  

---

**Last Review:** 2026-08-04  
**Branch:** `chore/agentic/first-run` (create-phase)
