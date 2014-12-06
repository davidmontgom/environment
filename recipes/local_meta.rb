data_bag("my_data_bag")
db = data_bag_item("my_data_bag", "my")
#location = node.name.split('-')[2]


datacenter = node.name.split('-')[0]
server_type = node.name.split('-')[1]
location = node.name.split('-')[2]



AWS_ACCESS_KEY_ID = db[node.chef_environment][location]['aws']['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = db[node.chef_environment][location]['aws']['AWS_SECRET_ACCESS_KEY']
class_path = db[node.chef_environment]['class_path']

monitor_server = "127.0.0.1"

=begin
directory "/home/ubuntu" do
  mode "0777"
  action :create
end
=end

directory "/etc/ec2" do
  mode "0755"
  recursive true
  action :create
end

=begin
aws_keys = node['environment']['aws']['keys'] 
aws_keys.each do |pem|
  cookbook_file "/etc/ec2/#{pem}" do
    source "#{pem}"
    mode 00644
  end
end
=end


template "/etc/ec2/meta_data.yaml" do
  path "/etc/ec2/meta_data.yaml"
  source "meta_data.yaml.erb"
  mode "0644"
  variables({
    :AWS_ACCESS_KEY_ID => "#{AWS_ACCESS_KEY_ID}", :AWS_SECRET_ACCESS_KEY => "#{AWS_SECRET_ACCESS_KEY}",
    :location => "#{location}", :datacenter => "#{datacenter}", :server_type => "#{server_type}", :environment => node.chef_environment,
    :class_path => "#{class_path}"
    #, :monitor_server => "#{monitor_server}"
  })
end