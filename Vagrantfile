#-*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "chef/centos-6.5"
  config.vm.network :private_network, type: :dhcp
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
  end
end
