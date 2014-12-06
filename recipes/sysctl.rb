template "/etc/sysctl.conf" do
  path "/etc/sysctl.conf"
  source "sysctl.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[restart_sysctl]", :immediately
end

execute "restart_sysctl" do
  command "sysctl -p /etc/sysctl.conf"
  action :nothing
end
 
=begin
execute "set_ulimit" do
#http://www.ubun2.com/question/433/how_set_ulimit_ubuntu_linux_getting_sudo_ulimit_command_not_found_error
command "ulimit -SHn 65535"
action :run
not_if {File.exists?("/tmp/ulimit_lock")}
end
=end

execute "modify_ulimit_www_soft" do
  command "echo 'www-data soft nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/tmp/ulimit_lock")}
end
execute "modify_ulimit_www_hard" do
  command "echo 'www-data hard nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/tmp/ulimit_lock")}
end
execute "modify_ulimit_root_soft" do
  command "echo 'root soft nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/tmp/ulimit_lock")}
end
execute "modify_ulimit_root_hard" do
  command "echo 'root hard nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/tmp/ulimit_lock")}
end
execute "modify_ulimit_all_soft" do
  command "echo '* soft nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/tmp/ulimit_lock")}
end
execute "modify_ulimit_all_hard" do
  command "echo '* hard nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/tmp/ulimit_lock")}
end
file "/tmp/ulimit_lock" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end