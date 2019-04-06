#https://www.tecmint.com/increase-set-open-file-limits-in-linux/

bash "restart_sysctl" do
  user "root"
  code <<-EOH
    sysctl -p /etc/sysctl.conf
    touch /var/chef/cache/sysctl.lock
  EOH
  action :nothing  
end

template "/etc/sysctl.conf" do
  path "/etc/sysctl.conf"
  source "sysctl.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "bash[restart_sysctl]", :immediately
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

cat /proc/sys/fs/file-max
200000

ulimit -Hn
100000

 ulimit -Sn
100000

 ulimit
unlimited


cat /proc/sys/net/core/somaxconn
=end

execute "modify_ulimit_www_soft" do
  command "echo 'www-data soft nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/var/chef/cache/ulimit.lock")}
end
execute "modify_ulimit_www_hard" do
  command "echo 'www-data hard nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/var/chef/cache/ulimit.lock")}
end
execute "modify_ulimit_root_soft" do
  command "echo 'root soft nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/var/chef/cache/ulimit.lock")}
end
execute "modify_ulimit_root_hard" do
  command "echo 'root hard nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/var/chef/cache/ulimit.lock")}
end
execute "modify_ulimit_all_soft" do
  command "echo '* soft nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/var/chef/cache/ulimit.lock")}
end
execute "modify_ulimit_all_hard" do
  command "echo '* hard nofile 100000' | tee -a /etc/security/limits.conf"
  action :run
  not_if {File.exists?("/var/chef/cache/ulimit.lock")}
end
execute "modify_somaxconn" do
  command "sysctl -w net.core.somaxconn=10000"
  action :run
  not_if {File.exists?("/var/chef/cache/ulimit.lock")}
end


file "/var/chef/cache/ulimit.lock" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

bash "restart_sysctl_redis" do 
  user "root"
  code <<-EOH
    sysctl -w fs.file-max=100000
    sysctl -p /etc/sysctl.conf
    touch /var/chef/cache/sysctl_redis.lock
  EOH
  action :run  
  not_if {File.exists?("/var/chef/cache/sysctl_redis.lock")}
end 