template "/etc/supervisor/conf.d/chef-client.conf" do
  path "/etc/supervisor/conf.d/chef-client.conf"
  source "supervisord.chefclient.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  variables({
    :interval => "240"
  })
  notifies :restart, resources(:service => "supervisord")
end
service "supervisord"
