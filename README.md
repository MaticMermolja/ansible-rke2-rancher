# Ansible RKE2 + Rancher Configuration

This Ansible script configures Oracle Linux 8 / CentOS 8 systems and installs RKE2 alongside Rancher.

## Quick start

### Prerequisites

Ensure the following packages and Python modules are installed on your master node:

- `python3-pip`
- `unzip`
- `nano`
- `epel-release`
- `ansible`

Additionally, you'll need to install the Kubernetes Python module:

```bash
pip3 install kubernetes
```

Make sure the master node has SSH access to all other nodes in the configuration.

1. Before running the playbook, execute generate_hosts.ini.sh from the master node:
```bash
sh ./generate_hosts.ini.sh
```
Follow the script instructions, entering all required IP addresses and FQDNs. This script will configure your hosts.ini file and update /etc/hosts on your master node.

2. Copy the configured hosts to all other nodes in your setup.
3. Update default variables in the defaults directory to match your expectations and configuration. To access Rancher make sure to change `rancher_hostname` in `roles/rancher/defaults/main.yml` to match your master node hostname.
4. Run the playbook:
```bash
ansible-playbook -i inventory/hosts.ini site.yml
```
## Script Overview
This project contains several roles:
- `system-config`: Configures the OS and installs required packages.
- `rke2-server`: Sets up server nodes and installs RKE2 on them.
- `rke2-worker`: Sets up worker nodes and installs RKE2 on them.
- `rancher`: Installs Rancher on selected nodes.