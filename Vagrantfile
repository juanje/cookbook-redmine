require 'berkshelf/vagrant'

Vagrant::Config.run do |config|
  config.vm.box = "redminebox"
  config.vm.box_url = "http://cloud-images.ubuntu.com/quantal/current/quantal-server-cloudimg-vagrant-i386-disk1.box"
  config.vm.forward_port 80, 8080
  config.vm.share_folder "redmine-code", "/code/cookbooks/redmine", "."
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = [[:vm, "/code"]]
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
    chef.add_recipe "redmine"
#    chef.log_level = :debug
  end
end
