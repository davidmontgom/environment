datacenter = node.name.split('-')[0]
location = node.name.split('-')[1]
environment = node.name.split('-')[2]
slug = node.name.split('-')[3] 
server_type = node.name.split('-')[4]

data_bag("meta_data_bag")
aws = data_bag_item("meta_data_bag", "aws")
AWS_ACCESS_KEY_ID = aws[node.chef_environment]['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = aws[node.chef_environment]['AWS_SECRET_ACCESS_KEY']


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
settings_path = "/var/#{slug}-settngs"

template "/etc/ec2/meta_data.yaml" do
  path "/etc/ec2/meta_data.yaml"
  source "meta_data.yaml.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}",
    :location => "#{location}", :datacenter => "#{datacenter}", 
    :server_type => "#{server_type}", :environment => "#{environment}",
    :class_path => "#{class_path}",:settings_path => "#{settings_path}",
    :slug => "#{slug}"
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

