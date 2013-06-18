Description
===========

Installs the ticketing box with Redmine from the source.

The cookbook will install Redmine with MySql as a database adaptor and Apache2
as a web server.

### Notes for the current cookbook's version

The current version only support MySql and it will be installed at the same
node, but the recipe will take care of it. MySql and Apache2 will be installed
by the recipe.
You don't need to install it previously.

Requirements
============

## Platform:

Tested on:

* Ubuntu (12.04, 12.10)
* CentOS (6.3, 6.4)

## Cookbooks:

* apt
* yum
* runit
* git
* apache2
* passenger\_apache2
* mysql
* postgresql
* build-essential
* openssl

If you are running different chef versions in your box, see
https://github.com/opscode-cookbooks/apt#requirements to configure proper apt
version in Berksfile 

### Test the cookbook with Vagrant

You need to have installed Vagrant version 1.1.X and the Berskshelf plugin:

```
$ vagrant plugin install vagrant-berkshelf
```

Then just: `vagrant up`

Remember that you can change some cookbook's behavior through the attributes in the `Vagrantfile`.
Chef the example at `chef.json`.


Attributes
==========

This cookbook uses many attributes, broken up into a few different kinds.

Usage
=====

This cookbook installs Redmine with a defaults confirations to have it working
out the box. But if you like to customize them, just chage it at the attributes.

The easy way is to create your own role and specify your preferences. Here is
an example:

    # roles/redmine.rb
    name "redmine"
    description "Redmine box to manage all the tickets"
    run_list("recipe[redmine]")
    default_attributes(
      "redmine" => {
        "databases" => {
          "production" => {
            "password" => "redmine_password"
          }
        }
      },
      "mysql" => {
        "server_root_password" => "supersecret_password"
      }
    )

Chef-solo tips
==============

If you are using chef-solo provider you must specify mysql password attributes:

    :mysql => {
         :server_root_password => "supersecret_password",
         :server_debian_password => "supersecret_password",
         :server_repl_password => "supersecret_password"
       }

See cookbook note: https://github.com/opscode-cookbooks/mysql#chef-solo-note

License and Author
==================

Author:: Juanje Ojeda (<juanje.ojeda@gmail.com>)
Author:: Roberto Majadas (<roberto.majadas at openshine.com>)

Copyright:: 2012-2013, Juanje Ojeda (<juanje.ojeda@gmail.com>)
Copyright:: 2013, Roberto Majadas (<roberto.majadas at openshine.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
