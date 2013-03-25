name             "redmine"
maintainer       "Juanje Ojeda"
maintainer_email "juanje.ojeda@gmail.com"
license          "Apache 2.0"
description      "Install Redmine from Github"
version          "0.0.4"

recipe "redmine", "Install the Redmine application from the source"

%w{ git apache2 passenger_apache2 mysql }.each do |dep|
  depends dep
end

%w{ debian ubuntu centos redhat amazon scientific fedora suse }.each do |os|
    supports os
end
