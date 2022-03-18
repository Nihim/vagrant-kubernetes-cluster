# -*- mode: ruby -*-
# vi: set ft=ruby :

K8_BOOTSTRAP    = true

MASTER_IP       = "172.16.8.10"
NODE_01_IP      = "172.16.8.11"
NODE_02_IP      = "172.16.8.12"

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder "vagrant_share/", "/vagrant"

  boxes = [
    { :name => "v-master",  :ip => MASTER_IP,  :cpus => 1, :memory => 4096 },
    { :name => "v-node-01", :ip => NODE_01_IP, :cpus => 1, :memory => 3072 },
    { :name => "v-node-02", :ip => NODE_02_IP, :cpus => 2, :memory => 3072 },
  ]
  # additional boxes should also be configured in install-kubernetes-dependencies.sh:configure_hosts_file

  boxes.each do |opts|
    config.vm.define opts[:name] do |box|
      box.vm.hostname = opts[:name]
      box.vm.network :private_network, ip: opts[:ip]
 
      box.vm.provider "virtualbox" do |vb|
        vb.cpus = opts[:cpus]
        vb.memory = opts[:memory]
        vb.name = opts[:name]
        vb.customize ["modifyvm", :id, "--vram", "16"]
        # vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
        vb.customize ["modifyvm", :id, "--vrde", "off"]
      end
      box.vm.provision "shell", path:"install-kubernetes-dependencies.sh"
      box.vm.provision "shell", path:"add-user-pub-key.sh" if(File.exist?('add-user-pub-key.sh'))

      if K8_BOOTSTRAP == true then
        if box.vm.hostname == "v-master" then
          box.vm.provision "shell", path:"configure-master-node.sh"
        end
        if box.vm.hostname.include? "node" then
          box.vm.provision "shell", path:"configure-worker-nodes.sh"
        end
      end

    end
  end
end
