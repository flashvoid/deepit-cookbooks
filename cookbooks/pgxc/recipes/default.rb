#
# Cookbook Name:: pgxc
# Recipe:: default
#
# Copyright 2013, deepIT
#
# All rights reserved - Do Not Redistribute
#

remote_file "/tmp/#{node["pgxc"]["package"]}" do
	source "#{node["pgxc"]["url"]}/#{node["pgxc"]["package"]}"
end

package "pgxc" do
	source "/tmp/#{node["pgxc"]["package"]}"
end
