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
default["redmine"]["databases"]["production"]["password"] = 'password'

# packages
# packages are separated to better tracking
case platform
when "redhat","centos","amazon","scientific","fedora","suse"
  default["redmine"]["packages"] = {
    "mysql"   => %w{ mysql-devel },
    "apache"  => %w{ zlib-devel curl-devel openssl-devel httpd-devel apr-devel apr-util-devel },
    "rmagick" => %w{ ImageMagick ImageMagick-devel },
    #TODO: SCM packages should be installed only if they are goin to be used
    #NOTE: git will be installed with a recipe because is needed for the deploy resource
    "scm"     => %w{ subversion bzr mercurial darcs cvs }
  }
when "debian","ubuntu"
  default["redmine"]["packages"] = {
    "mysql"   => %w{ libmysqlclient-dev },
    "apache"  => %w{ apache2-prefork-dev libapr1-dev libaprutil1-dev libcurl4-openssl-dev },
    "rmagick" => %w{ libmagickcore-dev libmagickwand-dev librmagick-ruby },
    #TODO: SCM packages should be installed only if they are goin to be used
    #NOTE: git will be installed with a recipe because is needed for the deploy resource
    "scm"     => %w{ subversion bzr mercurial darcs cvs }
  }
end

# gems
default["redmine"]["gems"]["bundler"] = ''
