# Heirarchy of Needs

| Stack Level | Description |
| :---: | ------------ |
| ▪️ | K8S Container Applications/Deployments (Runtime), Services |
| ▪️▪️ | External Secrets -> Secrets/ConfigMaps |
| ▪️▪️▪️ | PVC Configuration / StorageClasses, LoadBalancer Configured, Certificates Updated |
| ▪️▪️▪️▪️ | Operators Installed & Configured (ESO, CertBot) |
| ▪️▪️▪️▪️▪️ | Cluster Service Accounts Generated |
| ▪️▪️▪️▪️▪️▪️ | Cluster Deployed, Admin Credentials Stored, pfSense NAT established |
| ▪️▪️▪️▪️▪️▪️▪️ | Route53 DNS ARN stored, SDN Created in Proxmox, pfSense VM deployed & configured |
| ▪️▪️▪️▪️▪️▪️▪️▪️ | Proxmox User+API Key Usable by Terraform, skifree able to provision VMs + SDNs |
| ▪️▪️▪️▪️▪️▪️▪️▪️▪️ | Images to be used are uploaded to Proxmox node (Ubuntu, Talos metal.iso, etc) |
| ▪️▪️▪️▪️▪️▪️▪️▪️▪️▪️ | Primary runner agent online and token auth'd to GitHub homelab project |

A secondary `Day 2` set of needs will be established below for VM updates/maintenance activities, will be handled with whichever tool seems appropriate (Ansible?)
