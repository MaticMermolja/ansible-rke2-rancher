#!/bin/bash

# Confirm Oracle Linux 8
read -rp "Are you running Oracle Linux 8? (yes/no): " is_oracle
if [ "$is_oracle" != "yes" ]; then
    echo "System not supported."
    exit 1
fi

# Collect main FQDN
read -rp "What is the FQDN you will be using? (example: kubernetes1.rekono.local): " main_fqdn
domain=$(echo "$main_fqdn" | sed 's/^kubernetes1\.//') # Extract domain from FQDN

# Collect server and worker node counts
read -rp "How many server nodes will you use? " server_count
read -rp "How many worker nodes will you use? " worker_count

# Initialize array to hold the names of all nodes and their IPs
declare -a all_nodes=()
declare -a all_ips=()

# Ensure the inventory directory exists
mkdir -p ./inventory

# Start generating hosts.ini content in the ./inventory folder
{
echo "[all:vars]"
echo ""
echo "[server_nodes]"
} > ./inventory/hosts.ini

# Loop for server nodes
for ((i = 1; i <= server_count; i++)); do
    read -rp "What is the IP of server node $i (FQDN: kubernetes${i}.$domain)? " ip
    node_name="server0$i"
    all_nodes+=("$node_name") # Add server node name to array
    all_ips+=("$ip") # Add server node IP to array
    if [ "$i" -eq 1 ]; then
        # Assuming the first server node is where Ansible is running
        echo "$node_name ansible_host=$ip fqdn=kubernetes${i}.$domain ansible_connection=local" >> ./inventory/hosts.ini
    else
        echo "$node_name ansible_host=$ip fqdn=kubernetes${i}.$domain" >> ./inventory/hosts.ini
    fi
done

echo "" >> ./inventory/hosts.ini
echo "[worker_nodes]" >> ./inventory/hosts.ini

# Loop for worker nodes
for ((i = 1; i <= worker_count; i++)); do
    fqdn="kubernetes$((i + server_count)).$domain"
    read -rp "What is the IP of worker node $i (FQDN: $fqdn)? " ip
    node_name="worker0$i"
    all_nodes+=("$node_name") # Add worker node name to array
    all_ips+=("$ip") # Add worker node IP to array
    echo "$node_name ansible_host=$ip fqdn=$fqdn" >> ./inventory/hosts.ini
done

# Ask which nodes to designate as Rancher nodes
echo "Select the nodes to be designated as Rancher nodes by entering their numbers separated by spaces (e.g., 1 2 3):"
for i in "${!all_nodes[@]}"; do
    echo "$((i + 1))) ${all_nodes[$i]}"
done

read -rp "Enter selections: " -a selections

# Write selected Rancher nodes to hosts.ini
echo "" >> hosts.ini
echo "[rancher_nodes]" >> hosts.ini
for sel in "${selections[@]}"; do
    index=$((sel - 1))
    echo "${all_nodes[$index]}" >> hosts.ini
done

echo "hosts.ini file has been created successfully."

# Update /etc/hosts with entries for all nodes
for i in "${!all_nodes[@]}"; do
    fqdn="${all_nodes[$i]}.$domain"
    ip="${all_ips[$i]}"
    if ! grep -q "$fqdn" /etc/hosts; then
        echo "Adding $fqdn ($ip) to /etc/hosts"
        echo "$ip $fqdn" | sudo tee -a /etc/hosts
    else
        echo "$fqdn is already in /etc/hosts"
    fi
done

echo "/etc/hosts updated"