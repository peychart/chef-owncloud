#
# Cookbook Name:: chef-owncloud
# Recipe:: default
#
# Copyright (C) 2014 PE, pf.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Owncloud install:
bash "wgetrepokey" do
 code "wget -O /tmp/Release.key http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_#{node['platform_version']}/Release.key && apt-key add - < /tmp/Release.key"
 not_if { ::File.exists?('/etc/apt/sources.list.d/owncloud.list') }
end

template '/etc/apt/sources.list.d/owncloud.list' do
 source 'apt.sources.list.erb'
 owner 'root'
 group 'root'
 mode '0644'
 action :create
 not_if { ::File.exists?('/etc/apt/sources.list.d/owncloud.list') }
 notifies :run, "execute[apt-get update]", :immediately
end

execute 'apt-get update' do
  action :nothing
end

%w( owncloud php5-ldap php-apc libreoffice-common clamav clamav-daemon ).each do |pack|
  package pack do
    action :install
  end
end

bash "wgetantivirus" do
  code "wget -O /tmp/files_antivirus.tgz 'https://apps.owncloud.com/CONTENT/content-files/157439-files_antivirus.tar.gz' && cd /var/www/owncloud/apps && tar xzf /tmp/files_antivirus.tgz && chown -R root: /var/www/owncloud/apps/files_antivirus"
  not_if { ::File.exists?('/var/www/owncloud/apps/files_antivirus') }
end

bash "etclink" do
  code "[ -d /var/www/owncloud/config ] && ln -s /var/www/owncloud/config /etc/owncloud"
  not_if { ::File.exists?('/etc/owncloud') }
end

template '/etc/owncloud/config.php' do
  source 'config.php.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables({
    :instanceid => node['chef-owncloud']['instanceid'],
    :passwordsalt => node['chef-owncloud']['passwordsalt'],
    :secret => node['chef-owncloud']['secret'],
    :fqdn => node['fqdn'],
    :datadirectory => node['chef-owncloud']['datadirectory'],
    :forcessl => node['chef-owncloud']['ssl']['force'],
    :dbtype => node['chef-owncloud']['dbtype'],
    :dbhost => node['chef-owncloud']['dbhost'],
    :dbname => node['chef-owncloud']['dbname'],
    :dbuser => (node['chef-owncloud']['dbuser'] ? node['chef-owncloud']['dbuser'] : ''),
    :dbpassword => node['chef-owncloud']['dbpassword'],
    :language => node['chef-owncloud']['default_language'],
    :forcessl => (node['chef-owncloud']['ssl']['enable'] ? node['chef-owncloud']['ssl']['force'] : false),
    :other => node['chef-owncloud']['otheroptions']
  })
  not_if { ::File.exists?('/etc/owncloud/config.php') }
end

if node['chef-owncloud']['ssl']['enable']
  bash "setssl" do
    code <<-EOH
      a2enmod ssl
      a2ensite default-ssl
      a2enmod rewrite
      service apache2 reload
#      grep -w forcessl /etc/owncloud/config.php| grep -qsw true || ed /etc/owncloud/config.php <<EOF
#/);
#i
#  'forcessl' => true,
#.
#wq
#EOF
    EOH
  end
end

if node['chef-owncloud']['dbtype'] == 'mysql'
  bash 'mysqlInitPassword' do
    code <<-EOH
      while true; do
        service mysql stop && break
      done
      mysqld_safe --skip-grant-tables &
      sleep 2
      mysql -h localhost <<EOF
USE mysql
UPDATE user
SET password = password(\'#{node['chef-owncloud']['dbrootpassword']}\')
WHERE  USER = 'root' AND host = 'localhost';
quit
EOF
      while true; do
        mysqladmin shutdown && break
      done
      service mysql start
    EOH
  end if node['chef-owncloud']['dbrootpassword']

  bash 'createDatabase' do
    code <<-EOH
      mysql -u root -p#{node['chef-owncloud']['dbrootpassword']} <<EOF
USE mysql
CREATE DATABASE IF NOT EXISTS owncloud;
GRANT ALL PRIVILEGES ON owncloud.* TO \'#{node['chef-owncloud']['dbname']}\'@'localhost' IDENTIFIED BY \'#{node['chef-owncloud']['dbpassword']}\';
quit
EOF
    EOH
  end if node['chef-owncloud']['dbrootpassword']

 # Crontab:
  node['chef-owncloud']['crontab'].each do |name, description|
    cron name do
      minute  description['minute']
      hour    description['hour']
      day     description['day']
      month   description['month']
      weekday description['weekday']
      user    description['user']
      command description['command']
      path    description['path']
      mailto  description['mailto']
      action :create
    end
  end  if node['chef-owncloud']['crontab'] && node['chef-owncloud']['crontab'] != {}
end
