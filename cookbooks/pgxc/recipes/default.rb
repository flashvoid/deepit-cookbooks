#
# Cookbook Name:: pgxc
# Recipe:: default
#
# Copyright 2013, deepIT
#
# All rights reserved - Do Not Redistribute
#

bash "download-dist" do
	user "root"
	not_if "test -f /tmp/#{node['pgxc']['package']}"
	code <<-EOF
		wget "#{node["pgxc"]["url"]}/#{node["pgxc"]["package"]}" -O /tmp/#{node['pgxc']['package']}
	EOF
end

package "pgxc" do
	source "/tmp/#{node["pgxc"]["package"]}"
end

user "#{node['pgxc']['user']}" do
	username  "#{node['pgxc']['user']}"
	action :create
end

directory "#{node['pgxc']['datadir']}" do
	owner "#{node['pgxc']['user']}"
	mode "755"
	action :create
end
