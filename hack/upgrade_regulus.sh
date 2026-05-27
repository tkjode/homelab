#!/bin/sh

ssh bastion kubectl get nodes -o json  \
  | jq -rf genUpgradeCommands.jq  \
  | xargs -L 1 -I {} sh -c "{}"
