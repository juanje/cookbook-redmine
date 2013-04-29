# generic attribs
default["redmine"]["env"]       = 'production'
default["redmine"]["repo"]      = 'git://github.com/redmine/redmine.git'
default["redmine"]["revision"]  = '2.2.4'
default["redmine"]["deploy_to"] = '/opt/redmine'
default["redmine"]["path"]      = '/var/www/redmine'
default["redmine"]["install_method"] = "source"
default["redmine"]["install_rmagick"] = true

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
    "ruby"    => %w{ ruby-devel },
    "apache"  => %w{
      zlib-devel curl-devel openssl-devel httpd-devel apr-devel apr-util-devel
      mod_passenger
    },
    "rmagick" => %w{ ImageMagick ImageMagick-devel },
    "mysql"   => %w{ mysql-devel },
    "postgresql" => [],
    #TODO: SCM packages should be installed only if they are goin to be used
    #NOTE: git will be installed with a recipe because is needed for the deploy resource
    "scm"     => %w{ subversion bzr mercurial darcs cvs }
  }
when "debian","ubuntu"
  default["redmine"]["packages"] = {
    "ruby"    => %w{ ruby rubygems libruby ruby-dev },
    "apache"  => %w{
      libapr1-dev libaprutil1-dev libcurl4-openssl-dev
      libapache2-mod-passenger
    },
    "rmagick" => %w{ libmagickcore-dev libmagickwand-dev librmagick-ruby },
    "mysql"   => %w{ libmysqlclient-dev },
    "postgresql" => %w{ ruby-pg libpq-dev },
    #TODO: SCM packages should be installed only if they are goin to be used
    #NOTE: git will be installed with a recipe because is needed for the deploy resource
    "scm"     => %w{ subversion bzr mercurial darcs cvs }
  }
end
