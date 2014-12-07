
environment = node.environment
datacenter = node.name.split('-')[0]
server_type = node.name.split('-')[1]
location = node.name.split('-')[2]


data_bag("my_data_bag")
db = data_bag_item("my_data_bag", "my")
AWS_ACCESS_KEY_ID = db[node.environment][location]['aws']['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = db[node.environment][location]['aws']['AWS_SECRET_ACCESS_KEY']

monitor_server = db[node.environment][location]['monitor']['ip_address']



directory "/etc/ec2" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

=begin
if datacenter == "aws"
  cookbook_file "/etc/ec2/#{datacenter}_#{node.chef_environment}_#{location}.pem" do
    source "#{datacenter}_#{node.chef_environment}_#{location}.pem"
    mode 0600
  end
end
=end

file "/etc/ec2/#{node.chef_environment}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

class_path = node['environment']['class_path'] 
template "/etc/ec2/meta_data.yaml" do
  path "/etc/ec2/meta_data.yaml"
  source "meta_data.yaml.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}",
    :location => "#{location}", :datacenter => "#{datacenter}", :server_type => "#{server_type}", :environment => "#{environment}",
    :class_path => "#{class_path}", :monitor_server => "#{monitor_server}"
  })
end

package "tmux" do
  action :install
end
package "htop" do
  action :install
end
package "iftop" do
  action :install
end
package "telnet" do
  action :install
end

