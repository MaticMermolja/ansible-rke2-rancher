[all:vars]
ansible_user=your_ssh_user

[server_nodes]
server01 ansible_host=192.168.1.10 ansible_connection=local
server02 ansible_host=192.168.1.11

[worker_nodes]
worker01 ansible_host=192.168.1.20
worker02 ansible_host=192.168.1.21
worker03 ansible_host=192.168.1.22
