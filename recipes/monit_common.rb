service "monit"
template "/etc/monit/conf.d/common.conf" do
  path "/etc/monit/conf.d/common.conf"
  source "monit.common.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, resources(:service => "monit")
end