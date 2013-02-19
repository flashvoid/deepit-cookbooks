default["cloudstack"]["mgmt_fqdn"] = "cs"

case node[:platform]
when "ubuntu"
	default["cloudstack"]["ntp_package"] = "openntpd"
	default["cloudstack"]["template_installer"] = "/usr/lib/cloud/common/scripts/storage/secondary/cloud-install-sys-tmplt"
when "centos"
	default["cloudstack"]["template_installer"] = "/usr/lib64/cloud/common/scripts/storage/secondary/cloud-install-sys-tmplt"
	default["cloudstack"]["ntp_package"] = "ntp"
	default["cloudstack"]["mysqlservice"] = "mysqld"
else
	default["cloudstack"]["ntp_package"] = "ntp"
end




default["cloudstack"]["cloud_db_user"] = "cloud"
default["cloudstack"]["cloud_db_pass"] = "cloudpass"
