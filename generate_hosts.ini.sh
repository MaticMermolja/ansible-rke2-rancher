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

# Start generating hosts.ini content
{
echo "[all:vars]"
echo ""
echo "[server_nodes]"
} > hosts.ini

# Loop for server nodes
for ((i = 1; i <= server_count; i++)); do
    read -rp "What is the IP of server node $i (FQDN: kubernetes${i}.$domain)? " ip
    if [ "$i" -eq 1 ]; then
        # Assuming the first server node is where Ansible is running
        echo "server0$i ansible_host=$ip fqdn=kubernetes${i}.$domain ansible_connection=local" >> hosts.ini
    else
        echo "server0$i ansible_host=$ip fqdn=kubernetes${i}.$domain" >> hosts.ini
    fi
done

echo "" >> hosts.ini
echo "[worker_nodes]" >> hosts.ini

# Loop for worker nodes
for ((i = 1; i <= worker_count; i++)); do
    fqdn="kubernetes$((i + server_count)).$domain"
    read -rp "What is the IP of worker node $i (FQDN: $fqdn)? " ip
    echo "worker0$i ansible_host=$ip fqdn=$fqdn" >> hosts.ini
done

echo "hosts.ini file has been created successfully."
