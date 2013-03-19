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

Tested in:

* Debian (5.0 - Lenny)
* Ubuntu (10.04 - Lucid and 11.10 - Oneiric)
* CentOS (5.0)

## Cookbooks:

* apt
* yum
* runit
* git
* apache2
* passenger\_apache2
* mysql
* build-essential
* openssl

### Download the needed bookboks

I you don't have the cookbooks on your local repo, this lines could do the task:

    for cb in apt yum runit git apache2 passenger_apache2 mysql build-essential openssl ; do
      knife cookbook site install $cb
    done

### Upload the Redmine cookbook and its depends

Now you can upload the Redmine cookbook and its depends to the Chef server:

    knife cookbook upload redmine -d


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

Cookbook developer quickstart
=============================

1. Install bundler and Virtuabox packages
2. Execute the bootstrap script
```
$ ./bin/bootstrap
```
3. Activate the project environment
```
$ source ./bin/activate
```
4. Get to work :)
5. Test your work with vagrant
```
vagrant up
```
6. Deactivate the project environment
```
$ source ./bin/deactivate
```

License and Author
==================

Author:: Juanje Ojeda (<juanje.ojeda@gmail.com>)

Copyright:: 2012, Juanje Ojeda (<juanje.ojeda@gmail.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
