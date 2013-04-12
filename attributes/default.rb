# generic attribs
default["redmine"]["env"]       = 'production'
default["redmine"]["repo"]      = 'git://github.com/redmine/redmine.git'
default["redmine"]["revision"]  = '2.2.3'
default["redmine"]["deploy_to"] = '/opt/redmine'
default["redmine"]["path"]      = '/var/www/redmine'
default["redmine"]["install_method"] = "source"

# databases
default["redmine"]["databases"]["production"]["adapter"]  = 'mysql'
default["redmine"]["databases"]["production"]["database"] = 'redmine'
default["redmine"]["databases"]["production"]["username"] = 'redmine'
default["redmine"]["databases"]["production"]["password"] = 'password'
