service "monit"
template "/etc/monit/conf.d/firewall.conf" do
  path "/etc/monit/conf.d/firewall.conf"
  source "monit.firewall.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, resources(:service => "monit")
end