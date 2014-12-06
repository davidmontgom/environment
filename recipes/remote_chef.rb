data_bag("my_data_bag")
db = data_bag_item("my_data_bag", "my")
AWS_ACCESS_KEY_ID = db[node.environment]['aws']['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = db[node.environment]['aws']['AWS_SECRET_ACCESS_KEY']

validation_key= node['environment']['chef']['validation_key'] 
client_key = node['environment']['chef']['client_key'] 
validation_client_name = node['environment']['chef']['validation_client_name']
chef_server_url = node['environment']['chef']['chef_server_url'] 
node_name = node['environment']['chef']['node_name'] 
cookbook_path = node['environment']['chef']['cookbook_path']


environment = node.environment
if node.name.include? "-"
  datacenter = node.name.split('-')[0]
  server_type = node.name.split('-')[1]
  location = node.name.split('-')[2]
end
if node.name.include? "X"
  datacenter = node.name.split('X')[0]
  server_type = node.name.split('X')[1]
  location = node.name.split('X')[2]
end

directory "/root/.chef" do
  owner "root"
  group "root"
  mode "0777"
  recursive true
  action :create
end

cookbook_file "/root/.chef/#{validation_key}" do
  source "#{validation_key}"
  mode 00777
end

cookbook_file "/root/.chef/#{client_key}" do
  source "#{client_key}"
  mode 00777
end


if datacenter == "aws"
  template "/root/.chef/knife.rb" do
    path "/root/.chef/knife.rb"
    source "knife_aws.rb.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
      :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}",
      :validation_key => "#{validation_key}", :client_key => "#{client_key}", :validation_client_name => "#{validation_client_name}", 
      :chef_server_url => "#{chef_server_url}", :node_name => "#{node_name}", :cookbook_path => "#{cookbook_path}"
    })
  end
end

if datacenter == "do"
  template "/root/.chef/knife.rb" do
    path "/root/.chef/knife.rb"
    source "knife_aws.rb.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
      :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}",
      :validation_key => "#{validation_key}", :client_key => "#{client_key}", :validation_client_name => "#{validation_client_name}", 
      :chef_server_url => "#{chef_server_url}", :node_name => "#{node_name}", :cookbook_path => "#{cookbook_path}"
    })
  end
end
























