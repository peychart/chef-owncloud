#
# Cookbook Name:: chef-owncloud
# Attributes:: chef-owncloud
#
default['chef-owncloud']['datadirectory'] = '/var/www/owncloud/data'
default['chef-owncloud']['ssl']['enable'] = true
default['chef-owncloud']['ssl']['force'] = true

default['chef-owncloud']['otheroptions'] = [
  "'enable_avatars' => true",
  "",
  "'appstoreenabled' => false",
  "'blacklisted_files' => array('.htaccess')"
]

default['chef-owncloud']['dbtype'] = 'mysql'
default['chef-owncloud']['dbhost'] = '127.0.0.1'
default['chef-owncloud']['dbrootpassword'] = 'secret'
default['chef-owncloud']['dbname'] = 'owncloud'
default['chef-owncloud']['dbpassword'] = 'secret'


