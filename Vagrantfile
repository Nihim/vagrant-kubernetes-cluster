# -*- mode: ruby -*-
# vi: set ft=ruby :

K8_BOOTSTRAP    = true

MASTER_IP       = "172.16.8.20"
NODE_01_IP      = "172.16.8.21"

Vagrant.configure("2") do |config|
  config.ssh.insert_key = true
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder "vagrant_share/", "/vagrant"

  boxes = [
    { :name => "v-cka",  :ip => MASTER_IP,  :cpus => 1, :memory => 4096 },
    { :name => "v-ckanode-01", :ip => NODE_01_IP, :cpus => 1, :memory => 3072 },
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
        vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
        vb.customize ["modifyvm", :id, "--vrde", "off"]
      end
      box.vm.provision "shell", path:"add-user-pub-key.sh" if(File.exist?('add-user-pub-key.sh'))
      box.vm.provision "shell", path:"install-kubernetes-dependencies.sh"

      if K8_BOOTSTRAP == true then
        if box.vm.hostname == "v-cka" then
          box.vm.provision "shell", path:"configure-master-node.sh"
        end
        if box.vm.hostname.include? "node" then
          box.vm.provision "shell", path:"configure-worker-nodes.sh"
        end
      end

    end
  end
end
