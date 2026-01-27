# Journal / Changelog

## 2026-01-27

- __LetsEncrypt__
  - LetsEncrypt rate limits after 5 certificate requests in a 24 hour period, forcing a 24 hour wait time to cool down, I guess I'm borked for now.
  - This neccessitates externalizing the certificate store so that the gateway can be rebuilt but retain the certificates.
    - S3 plugins suck, going to create an NFS bind to a letsencrypt folder for the gateway to use as persistent storage. 
  - __Update:__ The NAS build has been sorted after some drama around `no_root_squash`, but there was trouble caused by certbot using a new folder when changing the order the certificates were raised in.
    - Updated the path but now haproxy still refuses to start up a boot time.
    - Attempts to crush network-wait-online do not appear to work, the command when run manually still hangs even though all networks are online and even with -i and --ignore options.

## 2026-01-26

- __DNS__
  - Took a look at the tcpdump on the gateway eth0 to see what traffic was being emitted while the cluster was idle and noticed a LOT of DNS requests were firing out to external DNS, so I decided to enable a caching/authoritative DNS server for the lab
  - bind9 + zone files created.  It would be great if this could also do DHCP IPAM so I can just get rid of the damn static IP addresses and let haproxy resolve stuff by name.
  - the outbound interface is much quieter now, no DNS exits the gateway hosts for the upstream unless it's looking for github, and even then b/c of caching it's rather rare.
- __Cluster Rebuild__
  - On rebuild I noticed the cluster workers did not all register with the new masters, only 1 managed to kubeadm join.
  - I was able to re-run cloud-init on each worker with `cloud-init clean && cloud-init --all-stages` and that got them joined up
  - I believe before workers can be joined, there should be a terraform check to validate that the masters are all checking in according to haproxy (eg. `curl -ks https://gateway:6443`) -- a valid response from the API means the worker builds should be OK to start.

## 2025-12-19

- Certbot installed and configured to serve LetsEncrypt certificates
  - [ ] TODO: Need to enable haproxy admin socket and implement an HAProxy cert injector post-update hook when certbot does its renewal.
- *Milestone:* Basic App Hosting Readiness upon bootstrap achieved.

## 2025-12-18

- Cluster build remains quite reliable and have sped it up a bit by removing the apt upgrade cycle at boot time, and just rely on `unattended-upgrades` to create chaos at 4:00am
- Used terraform to initialize a separate Certificate Authority - this is currently used to explicitly trust pods that serve HTTPS.  
  - [x] TODO: Noted that ArgoCD "hot reload" doesn't work if the `Secret` doesn't exist at startup - will need to do kustomization/helm hacks to ensure it's created early to allow hot-reload to recycle the pod.
    - Apparently not required, the last rebuild works through the envoy ingress using just the updated `TLSBackendPolicy` and cert trusts configured.
- Certificate popualtion with `cert-manager` is working well.  A `ClusterIssuer` is now deployed by ArgoCD, leveraging the kube-injected CA.
- Moved some ArgoCD projects around and gave the ApplicationSet the ability to define a project for each component.  They must be explicitly defined alongside the ApplicationSet creation otherwise the projects will not kick off.  Also removed the concept of a 'bios' namespace and cleaned up auto-creation of unneccessary namespaces.  The cluster bootstrap is now very low-cruft.
- Settled on Envoy Gateway Proxy, while a little complicated, it does grant a lot of power to configure things just right. 
- Retired the `Talos` projects and archived the `cloud-init-testing` projects for reference.
- Going to start working on post-boot k8s charts & features to deploy into the cluster, in no particular order:
  - HTPC Stack
    - Plex and/or Jellyfin
    - Sabnzbd
    - Sonarr/Radarr
  - Self-Hosted Development
    - gitea
    - code-server
    - kubernetes hosted runners for gitea
  - And more...


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