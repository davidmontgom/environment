server_type = node.name.split('-')[0]
slug = node.name.split('-')[1] 
datacenter = node.name.split('-')[2]
environment = node.name.split('-')[3]
location = node.name.split('-')[4]

data_bag("meta_data_bag")
aws = data_bag_item("meta_data_bag", "aws")
AWS_ACCESS_KEY_ID = aws[node.chef_environment]['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = aws[node.chef_environment]['AWS_SECRET_ACCESS_KEY']

class_path = node['environment']['class_path'] 
settings_path = "/var/#{slug}-settings"

if datacenter=='aws'
  region_id = node['ec2']['placement_availability_zone'].chop
else
  region_id = 'none'


template "/root/.bootops.yaml" do
  path "/root/.bootops.yaml"
  source "meta_data.yaml.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}",
    :location => "#{location}", :datacenter => "#{datacenter}", 
    :server_type => "#{server_type}", :environment => "#{environment}",
    :class_path => "#{class_path}",:settings_path => "#{settings_path}",
    :slug => "#{slug}", :region_id => "#{region_id}"
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
package "iotop" do
  action :install
end
package "ncdu" do
  action :install
end
package "telnet" do
  action :install
end

