# Cookbook Name:: redmine
# Recipe:: source
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

include_recipe "git"

#Setup system package manager
case node['platform']
when "debian","ubuntu"
  include_recipe "apt"
when "redhat","centos","amazon","scientific","fedora","suse"
  include_recipe "yum::epel"
end

#Install redmine required dependencies
case node['platform']
when "debian","ubuntu"
  %w{ruby rubygems libruby ruby-dev libmagickcore-dev libmagickwand-dev }.each do |package_name|
    package package_name do
      action :install
    end
  end
when "redhat","centos","amazon","scientific","fedora","suse"
  %w{ruby-devel ImageMagick ImageMagick-devel}.each do |package_name|
    package package_name do
      action :install
    end
  end
end

#Setup database
case node["redmine"]["databases"]["production"]["adapter"]
when "mysql"
  include_recipe "mysql::server"
  case node['platform']
  when "debian","ubuntu"
    include_recipe "database::mysql"
  when "redhat","centos","amazon","scientific","fedora","suse"
    include_recipe "database::mysql"
  end
when "postgresql"
  include_recipe "postgresql::server"
  case node['platform']
  when "debian","ubuntu"
    %w{ ruby-pg libpq-dev }.each do |package_name|
      package package_name do
        action :install
      end
    end
  when "redhat","centos","amazon","scientific","fedora","suse"
    include_recipe "database::postgresql"
  end
end

case node["redmine"]["databases"]["production"]["adapter"]
when "mysql"
  connection_info = {
    :host => "localhost",
    :username => 'root',
    :password => node['mysql']['server_root_password'].empty? ? '' : node['mysql']['server_root_password']
  }
when "postgresql"
  connection_info = {
    :host => "localhost",
    :username => 'postgres',
    :password => node['postgresql']['password']['postgres'].empty? ? '' : node['postgresql']['password']['postgres']
  }
end

database node["redmine"]["databases"]["production"]["database"] do
  connection connection_info
  case node["redmine"]["databases"]["production"]["adapter"]
  when "mysql"
    provider Chef::Provider::Database::Mysql
  when "postgresql"
    provider Chef::Provider::Database::Postgresql
  end
  action :create
end

database_user node["redmine"]["databases"]["production"]["username"] do
  connection connection_info
  password node["redmine"]["databases"]["production"]["password"]
  case node["redmine"]["databases"]["production"]["adapter"]
  when "mysql"
    provider Chef::Provider::Database::MysqlUser
  when "postgresql"
    provider Chef::Provider::Database::PostgresqlUser
  end
  action :create
end

database_user node["redmine"]["databases"]["production"]["username"] do
  connection connection_info
  database_name node["redmine"]["databases"]["production"]["database"]
  password node["redmine"]["databases"]["production"]["password"]
  case node["redmine"]["databases"]["production"]["adapter"]
  when "mysql"
    provider Chef::Provider::Database::MysqlUser
  when "postgresql"
    provider Chef::Provider::Database::PostgresqlUser
  end
  privileges [:all]
  action :grant
end

#Setup Apache
include_recipe "apache2"
case node['platform']
when "debian","ubuntu"
  %w{libapache2-mod-passenger}.each do |package_name|
    package package_name do
      action :install
    end
  end
when "redhat","centos","amazon","scientific","fedora","suse"
  %w{mod_passenger}.each do |package_name|
    package package_name do
      action :install
    end
  end
end

web_app "redmine" do
  docroot        ::File.join(node['redmine']['path'], 'public')
  template       "redmine.conf.erb"
  server_name    "redmine.#{node['domain']}"
  server_aliases [ "redmine", node['hostname'] ]
  rails_env      node['redmine']['env']
end

#Install Bundler
gem_package "bundler" do
  action :install
end

# deploy the Redmine app
deploy_revision node['redmine']['deploy_to'] do
  repo     node['redmine']['repo']
  revision node['redmine']['revision']
  user     node['apache']['user']
  group    node['apache']['group']
  environment "RAILS_ENV" => node['redmine']['env']
  #shallow_clone true

  before_migrate do
    %w{config log system pids}.each do |dir|
      directory "#{node['redmine']['deploy_to']}/shared/#{dir}" do
        owner node['apache']['user']
        group node['apache']['group']
        mode '0755'
        recursive true
      end
    end

    template "#{node['redmine']['deploy_to']}/shared/config/database.yml" do
      source "database.yml.erb"
      owner node['redmine']['user']
      group node['redmine']['group']
      mode "644"
      variables(
                :host => 'localhost',
                :databases => node['redmine']['databases'],
                :rails_env => node['redmine']['env']
                )
    end

    case node["redmine"]["databases"]["production"]["adapter"]
    when "mysql"
      execute "bundle install --without development test postgresql sqlite" do
        cwd release_path
      end
    when "postgresql"
      execute "bundle install --without development test mysql sqlite" do
        cwd release_path
      end
    end

    if Gem::Version.new(node['redmine']['revision']) < Gem::Version.new('2.0.0')
      execute 'rake generate_session_store' do
        cwd release_path
        not_if { ::File.exists?("#{release_path}/db/schema.rb") }
      end
    else
      execute 'rake generate_secret_token' do
        cwd release_path
        not_if { ::File.exists?("#{release_path}/config/initializers/secret_token.rb") }
      end
    end

  end

  migrate true
  migration_command 'rake db:migrate'

  before_restart do
    link node['redmine']['path'] do
      to release_path
    end
  end
  action :deploy
  notifies :restart, "service[apache2]"
end


