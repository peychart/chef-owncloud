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

template '/etc/apt/sources.list.d/owncloud.list' do
  source 'apt.sources.list.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

bash "wget" do
  code "wget -O /tmp/Release.key http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_#{node['platform_version']}/Release.key && apt-key add - < /tmp/Release.key"
end

execute 'apt-get update' do
  action :run
end

package 'owncloud' do
  package_name 'owncloud'
  action :install
end

bash "link" do
  code "if [ -d /var/www/owncloud/config ] && [ ! -d /etc/owncloud ]; then ln -s /var/www/owncloud/config /etc/owncloud; fi"
end

bash 'mysqlInitPassword' do
  code <<-EOH
    service mysql stop
    mysqld_safe --skip-grant-tables &
    sleep 2
    mysql -h localhost <<@@@
    USE mysql
    UPDATE user
    SET password = password(\'#{node['chef-owncloud']['mysql_root_password']}\')
    WHERE  USER = 'root' AND host = 'localhost';
    quit
    @@@
    mysqladmin shutdown
    service mysql start
    sleep 3
  EOH
end if node['chef-owncloud']['mysql_root_password']

bash 'createDatabse' do
  code <<-EOH
    mysql -u root -p #{node['chef-owncloud']['mysql_root_password']} <<@@@
    USE mysql
    CREATE USER \'#{node['chef-owncloud']['database_name']}\'@'localhost' IDENTIFIED BY \'#{node['chef-owncloud']['database_password']}\';
    CREATE DATABASE IF NOT EXISTS owncloud;
    GRANT ALL PRIVILEGES ON owncloud.* TO \'#{node['chef-owncloud']['database_name']}\'@'localhost' IDENTIFIED BY \'#{node['chef-owncloud']['database_password']}\';
    quit
    EOF
  EOH
end
