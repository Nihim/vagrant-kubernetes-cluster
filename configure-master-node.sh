#!/bin/bash -e

master_node=172.16.8.10
pod_network_cidr=192.168.0.0/16

initialize_master_node ()
{
systemctl enable kubelet
kubeadm config images pull
kubeadm init --apiserver-advertise-address=$master_node --pod-network-cidr=$pod_network_cidr --ignore-preflight-errors=NumCPU
}

create_join_command ()
{
kubeadm token create --print-join-command | tee /vagrant/join_command.sh
chmod +x /vagrant/join_command.sh
}

configure_kubectl () 
{
mkdir -p $HOME/.kube
cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

##For vagrant user
mkdir -p /home/vagrant/.kube
cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R 1000:1000 /home/vagrant/.kube
}

install_network_cni ()
{
kubectl apply -f /vagrant/kube-flannel.yml
}
create_master_node_key ()
{
su - vagrant -c "ssh-keygen -q -t ed25519 -N '' -f /home/vagrant/.ssh/id_ed25519"
cp /home/vagrant/.ssh/id_ed25519.pub /vagrant/master_node.pub
}

initialize_master_node
configure_kubectl
install_network_cni
create_join_command
create_master_node_key
