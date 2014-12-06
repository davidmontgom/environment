nodename = node.name.to_s.gsub('_', '-')

bash "aws_hostname" do
  user "root" 
  group "root"
  cwd "/etc/profile.d/"
  code <<-EOH
      echo '127.0.1.1 #{nodename} #{nodename}' | tee -a /etc/hosts
      > /etc/hostname
      echo '#{nodename}' | tee -a /etc/hostname
      /etc/init.d/hostname restart
      touch /var/chef/cache/aws_hostname
  EOH
  action :run
  not_if {File.exists?("/var/chef/cache/aws_hostname")}
end

