
easy_install_package "dop" do
  action :install
end
easy_install_package "timeout" do
  action :install
end
easy_install_package "stopwatch" do
  action :install
end
package "libffi-dev" do
  action :install
end

package "libssl-dev" do
  action :install
end

easy_install_package "paramiko" do
  options "-U"
  action :install
end
include_recipe "runit"
runit_service "monitorUfw"

service "monit"

template "/etc/monit/conf.d/monitorUfw.conf" do
  path "/etc/monit/conf.d/monitorUfw.conf"
  source "monit.monitorUfw.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, resources(:service => "monit"), :immediately
end