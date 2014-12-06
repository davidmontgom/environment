#location = node[:environment][:location]
#environment = node[:environment][:environment]

if Chef::Config[:solo]
  environment="local"      
else
  environment = node.chef_environment
end

data_bag("my_data_bag")
db = data_bag_item("my_data_bag", "my")
aws = db[environment]['aws']
AWS_ACCESS_KEY_ID = aws['aws_access_key_id']
AWS_SECRET_ACCESS_KEY = aws['aws_secret_access_key']


if Chef::Config[:solo]
  environment="local" 
  location="local"   
  datacenter="aws"
  server_type = "test"
  monitor_server = '127.0.0.1'  
  nodename = 'localhost'   
  ipaddress = "127.0.0.1"     
else
  location = node.name.split('X')[2]
  server_type = node.name.split('X')[1] 
  datacenter = node.name.split('X')[0]  
  monitor_server = db[environment]['monitor']['ip_address']
  nodename = node.name
  ipaddress = node[:ipaddress]
end



package "libyaml-dev" do
  action :install
end
package "python-yaml" do
  action :install
end

directory "/home/ubuntu/" do
  owner "root"
  group "root"
  mode "0600"
  action :create
  not_if {File.exists?("/home/ubuntu/")}
end

directory "/home/ubuntu/.ec2" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/home/ubuntu/.ec2")}
end

template "/home/ubuntu/.ec2/meta_data.yaml" do
  path "/home/ubuntu/.ec2/meta_data.yaml"
  source "meta_data.yaml.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :environment => "#{environment}", :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}",
    :location => "#{location}", :datacenter => "#{datacenter}", :server_type => "#{server_type}",:ipaddress => "#{ipaddress}", :nodename => "#{nodename}", 
    :monitor_server => "#{monitor_server}"
  })
end








