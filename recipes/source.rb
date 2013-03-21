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
end

#Setup DB adapter
case node['redmine']['db']['adapter']
when "mysql"
  include_recipe "mysql::server"
  mysql_packages = case node['platform']
                   when "centos", "redhat", "suse", "fedora", "scientific", "amazon"
                     %w{mysql mysql-devel}
                   when "ubuntu","debian"
                     %w{mysql-client libmysqlclient-dev ruby-mysql}
                   end

  mysql_packages.each do |package_name|
    package package_name do
      action :install
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
end

web_app "redmine" do
  docroot        ::File.join(node['redmine']['path'], 'public')
  template       "redmine.conf.erb"
  server_name    "redmine.#{node['domain']}"
  server_aliases [ "redmine", node['hostname'] ]
  rails_env      node['redmine']['env']
end


#Install redmine required dependencies
case node['platform']
when "debian","ubuntu"
  %w{bundler ruby-dev}.each do |package_name|
    package package_name do
      action :install
    end
  end

  %w{libpq-dev libmagickcore-dev libmagickwand-dev libsqlite3-dev}.each do |package_name|
    package package_name do
      action :install
    end
  end
end

# deploy the Redmine app
deploy_revision node['redmine']['deploy_to'] do
  repo     node['redmine']['repo']
  revision node['redmine']['revision']
  user     node['apache']['user']
  group    node['apache']['group']
  environment "RAILS_ENV" => node['redmine']['env']

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
                :rails_env => node['redmine']['env'],
                :revision => node['redmine']['revision']
                )
    end

    execute "bundle install --without development test" do
      cwd release_path
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


