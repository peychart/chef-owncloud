#
# Cookbook Name:: chef-owncloud
# Attributes:: chef-owncloud
#
default['chef-owncloud']['instanceid'] = 'oc20f46ea4fc'
default['chef-owncloud']['passwordsalt'] = 'f50d9de98551355ab46704241ea56d'
default['chef-owncloud']['secret'] = '5c5e498b7f1b079962a77972b8f0d0c1b6dbb99700f81dbc5ea69e5c7fab40c75a20be16364fd61bd3a9d907622bc9f9'
default['chef-owncloud']['apache_modules'] = ['rewrite']
default['chef-owncloud']['datadirectory'] = '/var/www/owncloud/data'
default['chef-owncloud']['ssl']['enable'] = true
default['chef-owncloud']['ssl']['force'] = true
default['chef-owncloud']['homeURL'] = true

default['chef-owncloud']['otheroptions'] = [
  "'enable_avatars' => true",
  "",
  "'appstoreenabled' => false",
  "'blacklisted_files' => array('.htaccess')"
]

default['chef-owncloud']['dbhost'] = '127.0.0.1'
default['chef-owncloud']['dbtype'] = 'mysql'
default['chef-owncloud']['dbrootpassword'] = 'secret'
default['chef-owncloud']['dbname'] = 'owncloud'
default['chef-owncloud']['dbuser'] = ''
default['chef-owncloud']['dbpassword'] = 'secret'
default['chef-owncloud']['crontab'] = {
  "owncloud"=> {
    "user"=> "www-data",
    "minute"=> "*/15",
    "command"=> "php -f /var/www/owncloud/cron.php"
  },
  "owncloud-dbBackup"=> {
    "user"=> "root",
    "weekday"=> "0",
    "hour"=> "0",
    "minute"=> "15",
    "command"=> "mysqldump --lock-tables -h localhost -u root -psecret owncloud > /tmp/owncloud-sqlbkp_$(date +\"\\%Y\\%m\\%d\").bak"
  }
}
