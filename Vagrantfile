# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty32"
  
  config.vm.hostname = "ubuntu-selenium-grid"
  
  config.vm.provision "shell",
    path: "provision.sh"

  # Selenium Server
  config.vm.network "forwarded_port", guest: 4444, host: 4444

end
