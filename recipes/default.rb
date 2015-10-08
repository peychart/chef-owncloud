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

# Provisionning:
#include_recipe 'chef-serviceAttributes::default'
#include_recipe 'chef-iscsiadm::default'
#include_recipe 'chef-lvm::default'
#include_recipe 'chef-mkswap::default'

# Owncloud install:
bash "wgetrepokey" do
 code "wget -O /tmp/Release.key http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_#{node['platform_version']}/Release.key && apt-key add - < /tmp/Release.key"
# not_if { ::File.exists?('/etc/apt/sources.list.d/owncloud.list') }
end

execute 'apt-get update' do
  action :nothing
end

template '/etc/apt/sources.list.d/owncloud.list' do
 source 'apt.sources.list.erb'
 owner 'root'
 group 'root'
 mode '0644'
 action :create
 variables({
   :version => node['platform_version']
 })
 not_if { ::File.exists?('/etc/apt/sources.list.d/owncloud.list') }
 notifies :run, "execute[apt-get update]", :immediately
end

%w( apache2 php5-ldap libreoffice-common clamav clamav-daemon php-apc php5-apcu owncloud ).each do |pack|
  package pack do
    action :install
  end
end

directory = node['chef-owncloud']['directory'].gsub(/\/$/, '')

bash "wgetantivirus" do
  code "wget -O /tmp/files_antivirus.tgz 'https://apps.owncloud.com/CONTENT/content-files/157439-files_antivirus.tar.gz' && cd #{directory}/apps && tar xzf /tmp/files_antivirus.tgz && chown -R root: #{directory}/apps/files_antivirus"
  not_if { ::File.exists?("#{directory}/apps/files_antivirus") }
end

bash "etclink" do
  code "[ -d /etc/owncloud ] || ln -s #{directory}/config /etc/owncloud; [ 0$(wc -l <#{directory}/config/config.php) -gt 6 ] || rm -f #{directory}/config/config.php"
end

template '/etc/owncloud/autoconfig.php' do
  source 'autoconfig.php.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
  variables({
    :passwordsalt => node['chef-owncloud']['passwordsalt'],
    :datadirectory => "#{directory}/data",
    :trustedDomains => node['chef-owncloud']['serverAliases'],
    :dbtype => node['chef-owncloud']['dbtype'],
    :dbname => node['chef-owncloud']['dbname'],
    :dbuser => node['chef-owncloud']['dbuser'],
    :dbpassword => node['chef-owncloud']['dbpassword'],
    :dbhost => node['chef-owncloud']['dbhost'],
    :dbtableprefix => node['chef-owncloud']['dbtableprefix'],
  })
  not_if { ::File.exists?('/etc/owncloud/config.php') }
end

template '/etc/owncloud/config.php' do
  source 'config.php.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
  variables({
    :instanceid => node['chef-owncloud']['instanceid'],
    :fqdn => node['fqdn'],
    :forcessl => node['chef-owncloud']['ssl']['force'],
    :language => node['chef-owncloud']['default_language'],
    :forcessl => (node['chef-owncloud']['ssl']['enable'] ? node['chef-owncloud']['ssl']['force'] : false),
    :proxy => node['chef-owncloud']['proxy'],
    :other => node['chef-owncloud']['otheroptions']
  })
  not_if { ::File.exists?('/etc/owncloud/config.php') }
end

node['chef-owncloud']['apache_modules'].each do |i|
  execute "apache_modules" do
    command "a2enmod #{i}"
    user 'root'
    action :run
  end
end

if node['chef-owncloud']['ssl']['enable']
  bash "setssl" do
    code <<-EOH
      a2enmod ssl
      a2ensite default-ssl
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

template '/etc/apache2/sites-available/owncloud.conf' do
  source 'owncloud.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables({
    :ip => node['ipaddress'],
    :enableSSL => node['chef-owncloud']['ssl']['enable'],
    :forceSSL => node['chef-owncloud']['ssl']['force'],
    :email => node['chef-owncloud']['email'],
    :serverName => node['chef-owncloud']['serverName'],
    :serverAliases => node['chef-owncloud']['serverAliases'],
    :directory => directory
  })
end

execute "apache_enable_owncloud" do
  command "a2ensite owncloud"
  user 'root'
  action :run
end

execute "apache_reload" do
  command "service apache2 reload"
  user 'root'
  action :run
  not_if { ::File.exists?('/etc/apache2/sites-enabled/owncloud.conf') }
end

if node['chef-owncloud']['dbtype'] == 'mysql'
  bash 'mysqlInitPassword' do
    code <<-EOH
      while true; do
        service mysql stop && break; sleep 1
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
        mysqladmin shutdown && break; sleep 1
      done
      service mysql start || service mysql restart
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

# complement IP Rules:
#include_recipe 'chef-iptables::default'

