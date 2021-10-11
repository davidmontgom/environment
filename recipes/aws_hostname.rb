
nodename = node.name
if node['platform_version'].to_f == 14.04
	if node.chef_environment!="local"
		bash "aws_hostname" do
		  user "root" 
		  group "root"
		  code <<-EOH
		      echo '127.0.1.1 #{nodename} #{nodename}' | tee -a /etc/hosts
		      > /etc/hostname
		      echo '#{nodename}' | tee -a /etc/hostname
		      service networking restart
		      service hostname restart
		      touch /var/chef/cache/aws_hostname
		  EOH
		  action :run
		  not_if {File.exists?("/var/chef/cache/aws_hostname")}
		end
	end
end

if node['platform_version'].to_f == 16.04
	if node.chef_environment!="local"
		bash "aws_hostname" do
		  user "root" 
		  group "root"
		  code <<-EOH
		      echo '127.0.1.1 #{nodename} #{nodename}' | tee -a /etc/hosts
		      > /etc/hostname
		      echo '#{nodename}' | tee -a /etc/hostname
		      hostnamectl set-hostname #{nodename}
		      systemctl restart systemd-logind.service
		      touch /var/chef/cache/aws_hostname
		  EOH
		  action :run
		  not_if {File.exists?("/var/chef/cache/aws_hostname")}
		end
	end
end

if node['platform_version'].to_f == 18.04
	if node.chef_environment!="local"
		bash "aws_hostname" do
		  user "root" 
		  group "root"
		  code <<-EOH
		      echo '127.0.1.1 #{nodename} #{nodename}' | tee -a /etc/hosts
		      > /etc/hostname
		      echo '#{nodename}' | tee -a /etc/hostname
		      hostnamectl set-hostname #{nodename}
		      systemctl restart systemd-logind.service
		      touch /var/chef/cache/aws_hostname
		  EOH
		  action :run
		  not_if {File.exists?("/var/chef/cache/aws_hostname")}
		end
	end
end


if node['platform_version'].to_f == 20.04
	if node.chef_environment!="local"
		bash "aws_hostname" do
		  user "root"
		  group "root"
		  code <<-EOH
		      echo '127.0.1.1 #{nodename} #{nodename}' | tee -a /etc/hosts
		      > /etc/hostname
		      echo '#{nodename}' | tee -a /etc/hostname
		      hostnamectl set-hostname #{nodename}
		      systemctl restart systemd-logind.service
		      touch /var/chef/cache/aws_hostname
		  EOH
		  action :run
		  not_if {File.exists?("/var/chef/cache/aws_hostname")}
		end
	end
end