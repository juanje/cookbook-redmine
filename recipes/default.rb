#
# Cookbook Name:: redmine
# Recipe:: default
#
# Copyright 2012, Juanje Ojeda <juanje.ojeda@gmail.com>
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

# set through recipes the base system
include_recipe "apt"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "passenger_apache2::mod_rails"
include_recipe "mysql::server"
include_recipe "git"


# install the dependencies
packages = node['redmine']['packages'].values.flatten
packages.each do |pkg|
  package pkg
end

node['redmine']['gems'].each_pair do |gem,ver|
  gem_package gem do
    action :install
    version ver if ver && ver.length > 0
  end
end


# set up the database
redmine_sql = '/tmp/redmine.sql'
template redmine_sql do
  source 'redmine.sql.erb'
  variables(
    :host => 'localhost',
    :databases => node['redmine']['databases']
  )
end

execute "create redmine database" do
  command "#{node['mysql']['mysql_bin']} -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }\"#{node['mysql']['server_root_password']}\" < #{redmine_sql}"
  action :nothing
  subscribes :run, resources("template[#{redmine_sql}]"), :immediately
  not_if { ::File.exists?("/var/lib/mysql/redmine") }
end


# create the directories and files needed for the deploy
directory node['redmine']['deploy_to'] do
  owner node['redmine']['owner']
  group node['redmine']['group']
  mode '0755'
  recursive true
end

directory "#{node['redmine']['deploy_to']}/shared/config" do
  owner node['redmine']['owner']
  group node['redmine']['group']
  mode '0755'
  recursive true
end

template "#{node['redmine']['deploy_to']}/shared/config/database.yml" do
  source "database.yml.erb"
  owner node['redmine']["owner"]
  group node['redmine']["group"]
  mode "644"
  variables(
    :host => 'localhost',
    :databases => node['redmine']['databases'],
    :rails_env => node['redmine']['env']
  )
end


# set up the Apache site
web_app "redmine" do
  docroot        ::File.join(node['redmine']['path'], 'public')
  template       "redmine.conf.erb"
  server_name    "redmine.#{node['domain']}"
  server_aliases [ "redmine", node['hostname'] ]
  rails_env      node['redmine']['env']
end

# this is because is the only site. Otherwise it should be removed
apache_site "000-default" do
  enable false
end

service "apache2"


# deploy the Redmine app
deploy_revision node['redmine']['deploy_to'] do
  repo     node['redmine']['repo']
  revision node['redmine']['revision']
  user     node['redmine']['owner']
  group    node['redmine']['group']
  environment "RAILS_ENV" => node['redmine']['env']
  shallow_clone true

  before_migrate do
    execute 'rake generate_session_store' do
      cwd release_path
      not_if { ::File.exists?("#{release_path}/db/schema.rb") }
    end
  end
  symlink_before_migrate "config/database.yml" => "config/database.yml"

  migrate true
  migration_command 'rake db:migrate'

  symlinks "config/database.yml" => "config/database.yml",
           "log"                 => "log",
           "system"              => "public/system"
  
  before_restart do
    link node['redmine']['path'] do
      to release_path
    end
  end
  action :deploy
  notifies :restart, "service[apache2]"
end
