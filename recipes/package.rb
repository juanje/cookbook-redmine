# Cookbook Name:: redmine
# Recipe:: package
#
# Copyright 2012, Juanje Ojeda <juanje.ojeda@gmail.com>
# Copyright 2013, Roberto Majadas <roberto.majadas@openshine.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform']
when "debian","ubuntu"
  include_recipe "apt"
end

case node["redmine"]["databases"]["production"]["adapter"]
when "mysql"
  include_recipe "mysql::server"
when "postgresql"
  include_recipe "postgresql::server"
end

include_recipe "apache2"

case node['platform']
when "debian","ubuntu"
  execute "preseed redmine" do
    command "debconf-set-selections /var/cache/local/preseeding/redmine.seed"
    action :nothing
  end

  case node["redmine"]["databases"]["production"]["adapter"]
  when "mysql"
    template "/var/cache/local/preseeding/redmine.seed" do
      source "debconf-redmine.seed.erb"
      owner "root"
      group "root"
      mode "0600"
      variables({
        :adapter => node["redmine"]["databases"]["production"]["adapter"],
        :db_name => node["redmine"]["databases"]["production"]["database"],
        :user => node["redmine"]["databases"]["production"]["username"],
        :password => node["redmine"]["databases"]["production"]["password"],
        :admin_pass => node['mysql']['server_root_password'].empty? ? '' : node['mysql']['server_root_password']
      })
      notifies :run, "execute[preseed redmine]", :immediately
    end

    %w{redmine-mysql redmine}.each do |package_name|
      package package_name do
        action :install
      end
    end
  when "postgresql"
    template "/var/cache/local/preseeding/redmine.seed" do
      source "debconf-redmine.seed.erb"
      owner "root"
      group "root"
      mode "0600"
      variables({
      :adapter => node["redmine"]["databases"]["production"]["adapter"],
      :db_name => node["redmine"]["databases"]["production"]["database"],
      :user => node["redmine"]["databases"]["production"]["username"],
      :password => node["redmine"]["databases"]["production"]["password"],
      :admin_pass => node['postgresql']['password']['postgres'].empty? ? '' : node['postgresql']['password']['postgres']
      })
      notifies :run, "execute[preseed redmine]", :immediately
    end

    %w{redmine-pgsql redmine}.each do |package_name|
      package package_name do
        ENV["LC_ALL"] = ENV["LANG"]
        ENV["LANGUAGE"] = ENV["LANG"]
        action :install
      end
    end
  end

  %w{libapache2-mod-passenger}.each do |package_name|
    package package_name do
      action :install
    end
  end

  link "/var/lib/redmine/default/passenger" do
    to "/usr/share/redmine"
    action :create
    owner node['apache']['user']
    group node['apache']['group']
  end

  directory "/var/lib/redmine/default/plugin_assets" do
    action :create
    owner node['apache']['user']
    group node['apache']['group']
  end

  if node['redmine']['http_server']['www_redirect'] || node['jenkins']['http_proxy']['ssl']['redirect_http']
    include_recipe "apache2::mod_rewrite"
  end

  if node['redmine']['http_server']['ssl']['enabled']
    include_recipe "apache2::mod_ssl"
  end

  apache_site "000-default" do
    enable false
    notifies :restart, "service[apache2]"
  end

  web_app node['redmine']['http_server']['web_app_name'] do
    docroot        "/usr/share/redmine/public"
    template       "apache2_redmine.conf.erb"
    server_name    node['redmine']['http_server']['host_name'] || node['fqdn']
    server_aliases node['redmine']['http_server']['host_aliases']
    rails_env      node['redmine']['env']
    install_method "dpkg"
    instance       "default"

    www_redirect     node['redmine']['http_server']['www_redirect']
    redirect_http    node['redmine']['http_server']['ssl']['redirect_http']
    ssl_enabled      node['redmine']['http_server']['ssl']['enabled']
    listen_ports     node['redmine']['http_server']['listen_ports']
    ssl_listen_ports node['redmine']['http_server']['ssl']['ssl_listen_ports']
  end

end
