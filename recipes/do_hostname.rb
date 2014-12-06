nodename = node.name.to_s.gsub('_', '-')
#nodename = nodename.to_s.gsub(' ', 'X')

=begin
execute "change_hostname" do
  command " echo '127.0.0.2 #{nodename}' | tee -a /etc/hosts"
  action :run
  not_if {File.exists?("#{Chef::Config[:file_cache_path]}/hostname")}
end
=end


bash "comment_hostname" do
  user "root"
  code <<-EOH
    #sed -i 's/^\(127\)/#\1/' /etc/hosts
    sed -i.bak 's/^127/#&/' /etc/hosts
  EOH
  action :run
  not_if {File.exists?("#{Chef::Config[:file_cache_path]}/hostname_test")}
end

execute "change_hostname" do
  command " echo '127.0.0.1 #{nodename} #{nodename}' | tee -a /etc/hosts"
  action :run
  not_if {File.exists?("#{Chef::Config[:file_cache_path]}/hostname_test")}
end
execute "change_hostname_restart" do
  command "/etc/init.d/hostname restart"
  action :run
  not_if {File.exists?("#{Chef::Config[:file_cache_path]}/hostname_test")}
end
=begin
execute "change_hostname" do
  command " echo '#{nodename}' > /etc/hostname;hostname -F /etc/hostname;/etc/init.d/hostname restart"
  action :run
  not_if {File.exists?("#{Chef::Config[:file_cache_path]}/hostname")}
end
=end
file "#{Chef::Config[:file_cache_path]}/hostname" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end
file "#{Chef::Config[:file_cache_path]}/hostname_test" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

