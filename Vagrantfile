#-*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "chef/centos-6.5"
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
  end
  config.vm.provision "shell", path: "common.sh"

  config.vm.define :ha do |ha|
    ha.vm.network :private_network, ip: "172.28.128.10"
    ha.vm.provision :shell, :path => "ha-setup.sh"
  end


  (1..5).each do |i|
    config.vm.define "pxc#{i}" do |pxcnode|
      pxcnode.vm.network :private_network, ip: "172.28.128.1#{i}"
      pxcnode.vm.provision :shell, :path => "pxc-setup.sh", :args => ["#{i}", "172.28.128.1#{i}"]
    end
  end

end
