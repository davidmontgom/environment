data_bag("my_data_bag")
db = data_bag_item("my_data_bag", "my")

datacenter = node.name.split('-')[0]
server_type = node.name.split('-')[1]
location = node.name.split('-')[2]

=begin
api = db[node.chef_environment][location]['api']
browser = db[node.chef_environment][location]['browser']
rexster = db[node.chef_environment][location]['rexster']
graphite = db[node.chef_environment][location]['monitor']
email = db[node.chef_environment]['email']
git_write_redis = db[node.chef_environment][location]['redis']['redisgitqueue']
cdn = db[node.chef_environment]['cdn']
AWS_ACCESS_KEY_ID = db[node.chef_environment][location]['aws']['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = db[node.chef_environment][location]['aws']['AWS_SECRET_ACCESS_KEY']
=end
directory "/etc/feeds" do
  mode "0666"
  recursive true
  action :create
end

=begin
template "/etc/feeds/settings.yaml" do
  path "/etc/feeds/settings.yaml"
  source "settings.yaml.erb"
  mode "0755"
  variables({
    :cdn => cdn, :git_write_redis => "#{git_write_redis}", :email => email, :location => "#{location}", :datacenter => "#{datacenter}", :server_type => "#{server_type}", :environment => node.chef_environment, :browser => browser, :api => api, :rexster => rexster,
    :graphite => graphite,:AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}",
  })
end
=end