# Journal / Changelog

## 2025-12-10

- Have a fairly reliable cluster build that has strong durability with generated CAs, keys and configurations.
- We can reboot the entire cluster stack from the hypervisor and it comes back like nothing happened.
- Have enabled `unattended-upgrades` operating semi-staggered (love that 4am chaos) and will see how that pans out
  - Fully expect to wake up at some point with a a dead cluster but whatever.
- Outstanding things to consider include:
  - To what should I connect my storage and how should it be hosted?
    - Still absolutely need SMB/NFS/FTP access on the network - I need Kubernetes to utilize it vs. host it
    - So it should be a resilient and stable service on the home network - K8S can reach out and get access to NFS paths no problem.
      - Will gateway ipv4.forwarding in-kernel be saturated by stuff like high-bandwidth media pulls if I run Jellyfish streams between networks?
      - Or should I expose the storage DIRECTLY into the cluster private network to avoid dog-legged traffic?
        - *Dual Homed*, *Direct-Connect-Storage* to Proxmox appears to be the least network traversal required.
  - ArgoCD bootstrapping - App of Apps, or App of Argo of Apps?
    - Let's start with App of Apps first b/c bootstrapping that has to happen anyway - only then once that's locked down should I look at App of Argos on top of it, then offload.

## 2025-11-18

- Reignited work on cloud-init deployment of a cluster on proxmox in the last few days
- Looking into Terraform file templating to help provide commonly re-used values into the cloud-init user and network sections
- Quick peek at suppying scripts for various provisioning actions, will need to be able to drop these into new machines and run them on first boot
  - Downloading kubelet & kubeadm
  - Maybe posting the initial admin kubeconfig somewhere, or just capturing it as a Terraform file output.

## 2025-04-12

- A little refactoring on GitHub Workflows and Actions
  - Created a reusable [action.yml](.github/actions/talos-apply/action.yml) that applies individual terraform components.  They're likely way too broken down and I have too many state files going on but we can blame earlier wonky behaviour from terraform/opentofu for breaking this up into smaller composable, easy to replay individual bits during troubleshooting.
  - Made the overall workflow steps way simpler by using a matrix strategy to just supply a list of folders I want applied in order.  I set the paralellism to 1 but, in theory, larger chunks of composable infrastructure could be applied simultaneously so long as they don't have depedencies.  The choice to single-tfify a whole build would be smart the moment I need to build multiple clusters across multiple environments, the modules can collapse and terraform can handle the dependencies while leveraging workspaces to manage state-by-env.
- Learned that proxmox is smart enough to ungzip an image, but you have to tell it the output filename.  And that if you supply proxmox with a directive to un-gzip a file you downloaded, it will auto-ungzip it on its own, then try it AGAIN and fail.  __All you need is the rename, nothing more!__
- Learned a bit about Privilege Separation on Proxmox API keys - if this is enabled, the API Key does not inherit the capabilities of the User it is associated with.  This can be useful if you are managing multiple environments and need to hand out specific keys to things with separated privs but don't want to create new full-on Users just to cut individual API keys from.
- Moved all of the environment variables for the Talos build into the entire GitHub Workflow step instead of on Per-Job - once again avoiding repetition where possible.  This was also done because moving all of the jobs to a matrix strategy pushes all job runs to require some consistency.  Individiual "Phases" of the build can be supplied with specific vars, but generally I'll likely keep them global basis since I'm only building 1 cluster right now.