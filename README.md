# vagrant-kubernetes-cluster

Kubernetes cluster automation via Vagrant

# Prerequisites

To create VMs with vagrant, you need to install:
- Vagrant (This project is tested on Vagrant 2.2.7)
- Virtualbox (This project is tested on Virtualbox 6.1.28)

# loke modifications

## user ssh authentication
You can add your public ssh key in all the VMs by creating a file named `add-user-pub-key.sh` with the following contents:
```
#! /bin/sh
echo '<your pub key here>' >> /home/vagrant/.ssh/authorized_keys
```
## K8s bootstrap

If you prefer to configure kubernetes yourself, you can set `K8_BOOTSTRAP = false` in the Vagrantfile, that way only the dependencies will be installed

## notes
In case vagrant ssh \<machine\> gives you trouble concerning key permissions and you can't modify them in windows set `config.ssh.insert_key = false`

# Usage

To create VMs and bootstrap your kubernetes cluster

`vagrant up`

After creation of VMs is complete ssh into master and check kubernetes cluster status

`vagrant ssh master` or connect via NAT / host-only adapter using your key

`kubectl get nodes`

To check your kubernetes cluster, you can create an nginx deployment and expose it (from port 30080) with

`kubectl apply -f /vagrant/nginx-deployment.yml && kubectl apply -f /vagrant/nginx-service.yml`

After deployment you can check your page with 

`curl http://<worker-ip>:30080`

