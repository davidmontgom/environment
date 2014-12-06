service "monit"
template "/etc/monit/conf.d/chef-client.conf" do
  path "/etc/monit/conf.d/chef-client.conf"
  source "monit.chefclient.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, resources(:service => "monit")
end