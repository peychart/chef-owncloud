#
# Cookbook Name:: chef-owncloud
# Attributes:: chef-owncloud
#
default['chef-owncloud']['instanceid'] = 'oc20f46ea4fc'
default['chef-owncloud']['passwordsalt'] = ''
default['chef-owncloud']['apache_modules'] = ['rewrite']
default['chef-owncloud']['serverName'] = node['fqdn']
default['chef-owncloud']['directory'] = '/var/www/owncloud'
default['chef-owncloud']['serverAliases'] = []
default['chef-owncloud']['ssl']['enable'] = true
default['chef-owncloud']['ssl']['force'] = true
default['chef-owncloud']['homeURL'] = true
default['chef-owncloud']['email'] = 'admin@my.domain'
default['chef-owncloud']['proxy'] = ''

default['chef-owncloud']['otheroptions'] = [
  "'enable_avatars' => true",
  "",
  "'appstoreenabled' => false",
  "'blacklisted_files' => array('.htaccess')"
]

default['chef-owncloud']['dbhost'] = 'localhost'
default['chef-owncloud']['dbtype'] = 'mysql'
default['chef-owncloud']['dbtableprefix'] = 'oc_'
default['chef-owncloud']['dbrootpassword'] = 'secret'
default['chef-owncloud']['dbname'] = 'owncloud'
default['chef-owncloud']['dbuser'] = 'owncloud'
default['chef-owncloud']['dbpassword'] = 'secret'
default['chef-owncloud']['crontab'] = {
  "owncloud"=> {
    "user"=> "www-data",
    "minute"=> "*/15",
    "command"=> "php -f /var/www/owncloud/cron.php >/dev/null 2>&1"
  },
  "owncloud-dbBackup"=> {
    "user"=> "root",
    "weekday"=> "0",
    "hour"=> "0",
    "minute"=> "15",
    "command"=> "prefix=/var/www/owncloud/data/updater_backup; sufix=_$(date +\"\\%Y\\%m\\%d-\\%H\\%M\\%S\"); mysqldump --lock-tables -h localhost -u root -psecret owncloud >\$prefix/owncloud-sqlbkp\$sufix.dump && cp /var/www/owncloud/config/config.php \$prefix/config\$sufix.php; find \$prefix -type f -exec chmod 400 {} \\;"
  }
}
