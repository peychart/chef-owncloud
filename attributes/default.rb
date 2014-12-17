#
# Cookbook Name:: chef-owncloud
# Attributes:: chef-owncloud
#
default['chef-owncloud']['datadirectory'] = '/var/www/owncloud/data'
default['chef-owncloud']['ssl']['enable'] = true
default['chef-owncloud']['ssl']['force'] = true
default['chef-owncloud']['proxy'] = ''

default['chef-owncloud']['default_language'] = 'fr'

default['chef-owncloud']['dbtype'] = 'mysql'
default['chef-owncloud']['dbhost'] = 'localhost'
default['chef-owncloud']['dbrootPassword'] = 'secret'
default['chef-owncloud']['dbname'] = 'owncloud'
default['chef-owncloud']['dbpassword'] = 'secret'
