package "python-dev" do
  action :install
end
package "python-setuptools" do
  action :install
end
easy_install_package "pyyaml" do
  action :install
end
easy_install_package "psutil" do
  action :install
end

cookbook_file "/var/local/node_agent.py" do
  source "node_agent.py"
  mode 00744
end

include_recipe "runit"
runit_service "nodeAgent"

#include_recipe "logrotate"
logrotate_app "nodeAgent-rotate" do
  cookbook "logrotate"
  path ["/tmp/nodeAgent.log"]
  frequency "daily"
  rotate 7
  #size "10M"
  create "644 root root"
end

