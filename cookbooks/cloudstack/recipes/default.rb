#
# Cookbook Name:: cloudstack
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

Defaults:cloud !requiretty

bash "cloud_sudo" do
	user "root"
	cwd  "/tmp"
	not_if "grep Defaults:cloud /etc/sudoers"
	code <<-EOH
		echo Defaults:cloud !requiretty >> /etc/sudoers
	EOH
end

#bash "set_hostname" do
#	user "root"
#	cwd  "/tmp"
#	code <<-EOH
#		hostname #{node["cloudstack"]["mgmt_fqdn"]}
#	EOH
#end

package "#{node["cloudstack"]["ntp_package"]}" do
	action :install
end


case node[:platform]
when "centos"
	cookbook_file "/etc/yum.repos.d/cloudstack.repo" do
		action :create
	end
end

package "cloud-client" do
	action :install
end

package "mysql-server" do
	action :install
end

service "#{node["cloudstack"]["mysqlservice"]}" do
	action :start
end

bash "create_cloud_db" do
	user "root"
	cwd  "/tmp"
	not_if "test -f /var/chef/create_cloud_db.token"
	code <<-EOH
		cloud-setup-databases cloud:#{node["cloudstack"]["cloud_db_pass"]}@localhost --deploy-as=root
		[[ "$?" == "0" ]] && touch /var/chef/create_cloud_db.token
	EOH
end

directory "/exports" do
	owner "root"
	mode "777"
	action :create
end

directory "/exports/primary" do
	owner "root"
	mode "777"
	action :create
end

directory "/exports/secondary" do
	owner "root"
	mode "777"
	action :create
end

file "/etc/exports" do
	mode "644"
	content "/export  *(rw,async,no_root_squash)"
end

bash "export" do
	user "root"
	code <<-EOH
		exportfs -a
	EOH
end

cookbook_file "/etc/sysconfig/nfs" do
	action :create
end

bash "firewall_routine" do 
	user "root"
	cwd "tmp"
	not_if "grep -a 8080 /etc/sysconfig/iptables"
	code <<-EOH
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -A INPUT -m state --state NEW -p udp --dport 111 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 111 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 2049 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 32803 -j ACCEPT
iptables -A INPUT -m state --state NEW -p udp --dport 32769 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 892 -j ACCEPT
iptables -A INPUT -m state --state NEW -p udp --dport 892 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 875 -j ACCEPT
iptables -A INPUT -m state --state NEW -p udp --dport 875 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 662 -j ACCEPT
iptables -A INPUT -m state --state NEW -p udp --dport 662 -j ACCEPT                
iptables -A INPUT -m state --state NEW -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
iptables-save > /etc/sysconfig/iptables
	EOH
end

bash "install_sys_templates" do
	user "root"
	cwd "/tmp"
	not_if "test -d /exports/secondary/template"
	code <<-EOH
		#{node["cloudstack"]["template_installer"]} -m /exports/secondary -u http://download.cloud.com/templates/acton/acton-systemvm-02062012.vhd.bz2 -h xenserver -F	
		#{node["cloudstack"]["template_installer"]} -m /exports/secondary -u http://download.cloud.com/templates/burbank/burbank-systemvm-08012012.ova -h vmware -F	
		#{node["cloudstack"]["template_installer"]} -m /exports/secondary -u http://download.cloud.com/templates/acton/acton-systemvm-02062012.qcow2.bz2 -h kvm -F	
	EOH
end

service "cloud-management" do
	action :start
end
