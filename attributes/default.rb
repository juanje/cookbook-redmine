# generic attribs
default["redmine"]["env"]       = 'production'
default["redmine"]["repo"]      = 'git://github.com/redmine/redmine.git'
default["redmine"]["revision"]  = '1.4.1'
default["redmine"]["deploy_to"] = '/opt/redmine'
default["redmine"]["path"]      = '/var/www/redmine'

# databases
default["redmine"]["databases"]["production"]["adapter"]  = 'mysql'
default["redmine"]["databases"]["production"]["database"] = 'redmine'
default["redmine"]["databases"]["production"]["username"] = 'redmine'
default["redmine"]["databases"]["production"]["password"]  = 'password'

# packages
# packages are separated to better tracking
case platform
when "redhat","centos","scientific","fedora","suse"
  default["redmine"]["owner"] = 'apache'
  default["redmine"]["group"] = 'apache'
  default["redmine"]["packages"]["mysql"]   = %w{ mysql-devel }
  default["redmine"]["packages"]["apache"]  = %w{ zlib-devel curl-devel openssl-devel httpd-devel apr-devel apr-util-devel }
  default["redmine"]["packages"]["rmagick"] = %w{ ImageMagick ImageMagick-devel }
  #TODO: SCM packages should be installed only if they are goin to be used
  #NOTE: git will be installed with a recipe because is needed for the deploy resource
  default["redmine"]["packages"]["scm"]     = %w{ subversion bzr mercurial darcs cvs }
when "debian","ubuntu"
  default["redmine"]["owner"] = 'www-data'
  default["redmine"]["group"] = 'www-data'
  default["redmine"]["packages"]["mysql"]   = %w{ libmysqlclient-dev }
  default["redmine"]["packages"]["apache"]  = %w{ apache2-prefork-dev libapr1-dev libaprutil1-dev libcurl4-openssl-dev }
  default["redmine"]["packages"]["rmagick"] = %w{ libmagickcore-dev libmagickwand-dev librmagick-ruby }
  #TODO: SCM packages should be installed only if they are goin to be used
  #NOTE: git will be installed with a recipe because is needed for the deploy resource
  default["redmine"]["packages"]["scm"]     = %w{ subversion bzr mercurial darcs cvs }
end

# gems
default["redmine"]["gems"]["passenger"] = ''
default["redmine"]["gems"]["bundler"]   = ''
