#!/bin/bash -e


install_required_packages ()
{
apt update && apt upgrade -y
apt -y install curl apt-transport-https ca-certificates
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt update
apt -y install vim git curl wget kubelet=1.24.6-00 kubeadm=1.24.6-00 kubectl=1.24.6-00
apt-mark hold kubelet kubeadm kubectl
}

configure_hosts_file ()
{
tee /etc/hosts<<EOF
172.16.8.20 v-cka
172.16.8.21 v-ckanode-01
EOF
}

disable_swap () 
{
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a
}

configure_sysctl ()
{
modprobe overlay
modprobe br_netfilter
tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
}

install_docker_runtime () 
{
apt update
apt install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt update
apt install -y containerd.io docker-ce docker-ce-cli
mkdir -p /etc/systemd/system/docker.service.d
tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

systemctl daemon-reload
systemctl restart docker
systemctl enable docker

sed -i 's/plugins.cri.systemd_cgroup = false/plugins.cri.systemd_cgroup = true/' /etc/containerd/config.toml
sed -i 's/disabled_plugins = \["cri"\]/#&/' /etc/containerd/config.toml
systemctl restart containerd
}

install_required_packages
configure_hosts_file
disable_swap
configure_sysctl
install_docker_runtime
