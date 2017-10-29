package "python-dev" do
  action :install
end

package "python-setuptools" do
  action [:install,:upgrade]
end

python_package 'pyyaml' 

python_package "psutil" do
  action [:install, :upgrade]
end

execute "restart_node_agent" do
  command "sudo supervisorctl restart node_agent_server:"
  action :nothing
end

cookbook_file "/var/node_agent.py" do
  source "node_agent.py"
  mode 00744
  notifies :run, "execute[restart_node_agent]"
end

template "/etc/supervisor/conf.d/supervisord.node.agent.include.conf" do
  path "/etc/supervisor/conf.d/supervisord.node.agent.include.conf"
  source "supervisord.node.agent.include.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, resources(:service => "supervisord"), :immediately 
end
service "supervisord"

=begin
include_recipe "runit"
runit_service "nodeAgent"

#include_recipe "logrotate"
logrotate_app "nodeAgent-rotate" do
  cookbook "logrotate"
  path ["/tmp/nodeAgent.log"]
  frequency "daily"
  rotate 1
  size "1M"
  create "644 root root"
end
=end
