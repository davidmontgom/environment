server_type = node.name.split('-')[0]
slug = node.name.split('-')[1] 
datacenter = node.name.split('-')[2]
environment = node.name.split('-')[3]
location = node.name.split('-')[4]

data_bag("meta_data_bag")
aws = data_bag_item("meta_data_bag", "aws")
AWS_ACCESS_KEY_ID = aws[node.chef_environment]['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = aws[node.chef_environment]['AWS_SECRET_ACCESS_KEY']


directory "/root/.aws" do
  mode "0644"
  recursive true
  action :create
end


template "/root/.aws/credentials" do
  path "/root/.aws/credentials"
  source "aws_credentials.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}"
  })
end 

template "/root/.aws/config" do
  path "/root/.aws/config"
  source "aws_config.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}"
  })
end 
