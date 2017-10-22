
nodename = node.name

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