# Cookbook Name:: nagios
# Recipe:: apache
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_php5"

group = "#{node['nagios']['users_databag_group']}"
sysadmins = search(:users, "groups:#{group}")

apache_site "000-default" do
  enable false
end

if node['public_domain']
  public_domain = node['public_domain']
else
  public_domain = node['domain']
end

template "#{node['apache']['dir']}/sites-available/nagios3.conf" do
  source "apache2.conf.erb"
  mode 00644
  variables :public_domain => public_domain
  if ::File.symlink?("#{node['apache']['dir']}/sites-enabled/nagios3.conf")
    notifies :reload, "service[apache2]"
  end
end

file "#{node['apache']['dir']}/conf.d/nagios3.conf" do
  action :delete
end

apache_site "nagios3.conf"
