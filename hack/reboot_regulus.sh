#!/bin/sh

ssh bastion kubectl get nodes -o json  \
  | jq -rf genClusterMaintenanceCommands.jq  \
  | xargs -L 1 -I {} sh -c "{}"
