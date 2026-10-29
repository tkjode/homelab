#!/bin/bash
set -euo pipefail
cd /home/tkjode/Dev/homelab

# Ensure main points to the head commit that already has the bump
git checkout main
git fetch origin main
git reset --hard origin/main

# Apply the patch
git checkout origin/main -- base/builds/regulus/argocd/projects/inference/manifests/open-webui/Deployment-open-webui.yaml
git add -A

# Commit
git commit -m "feat(regulus:inference): bump openwebui from v0.12.0-slim to v0.12.5-slim

## Summary

Update the Open-WebUI inference container image from `v0.12.0-slim` to `v0.12.5-slim`.

## Changes

| File | Change |
|------|--------|
| `base/builds/regulus/argocd/projects/inference/manifests/open-webui/Deployment-open-webui.yaml` | image tag from `-0.12.0-slim` to `-0.12.5-slim` |

## Changelog

See upstream: https://github.com/open-webui/open-webui/releases/tag/v0.12.5

## Deployment notes

- ArgoCD will reconcile the update
- Deployment uses `Recreate` strategy, so pods are fully replaced
- Users will need to reconnect to their chat sessions
"

# Clean up any untracked files that shouldn't be in the PR
git reset HEAD~3 -- . 2>/dev/null || true
git add .

# Push the branch
git push -u origin feat/regulus/inference/open-webui-0.12.5-slim

echo "✓ Branch pushed. PR to create: https://github.com/tkjode/homelab/pull/new/feat/regulus/inference/open-webui-0.12.5-slim"