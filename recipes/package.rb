#
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

case node['redmine']['db']['adapter']
when "mysql"
  include_recipe "mysql::server"
end

include_recipe "apache2"

case node['platform']
when "debian","ubuntu"
  execute "preseed redmine" do
    command "debconf-set-selections /var/cache/local/preseeding/redmine.seed"
    action :nothing
  end

  template "/var/cache/local/preseeding/redmine.seed" do
    source "debconf-redmine.seed.erb"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, "execute[preseed redmine]", :immediately
  end

  case node['redmine']['db']['adapter']
  when "mysql"
    %w{redmine-mysql redmine}.each do |package_name|
      package package_name do
        action :install
      end
    end
  end

  %w{libapache2-mod-passenger}.each do |package_name|
    package package_name do
      action :install
    end
  end

  web_app "redmine" do
    template "dpkg-redmine.conf.erb"
  end
end


