# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "opscode-ubuntu-12.04_chef-11.4.4"
  config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.4.4.box"

  config.vm.network :private_network, ip: "34.33.33.10"

  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "redmine"
  
    chef.json = {
      :redmine => {
        :databases => {
          :production => {
            :password => "redmine_password"
          }
        }
      },
      :mysql => {
        :server_root_password => "supersecret_password",
        :server_repl_password => "supersecret_password",
        :server_debian_password => "supersecret_password"
      }
    }
  end

end
