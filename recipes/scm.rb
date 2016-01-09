datacenter = node.name.split('-')[0]
environment = node.name.split('-')[1]
location = node.name.split('-')[2]
server_type = node.name.split('-')[3]
slug = node.name.split('-')[4] 
cluster_slug = File.read("/var/cluster_slug.txt")
cluster_slug = cluster_slug.gsub(/\n/, "") 

data_bag("meta_data_bag")
git = data_bag_item("meta_data_bag", "git")
git_account = git["git_account"]

data_bag("server_data_bag")
this_data_bag = data_bag_item("server_data_bag", "#{server_type}")


package "git-core" do
  action :install
end

if node.chef_environment == "development"
    branch_name = "development"
elsif node.chef_environment == "staging"
    branch_name = "staging"
else
    branch_name = "master"
end


=begin
bash "auth_git" do
  user "root"
  code <<-EOH
    touch /root/.ssh/config
    echo "StrictHostKeyChecking no" | tee -a /root/.ssh/config
    echo "yes" | ssh -T git@github.com
  EOH
  not_if {File.exists?("/root/.ssh/config")}
  action :run
  ignore_failure true
end
=end


git_repos = this_data_bag[datacenter][environment][location][cluster_slug]['git_repos'] 
git_repos.each do |repo|

  execute "git_stash" do
    cwd "/var/#{repo}"
    command "git stash"
    action :run
    only_if {File.exists?("/var/#{repo}")}
  end

  
  
  if repo.include? "bootops" 
    git "/var/#{repo}" do
        repository "git@github.com:davidmontgom/#{repo}.git"
        revision branch_name
        action :sync
        user "root"
    end

  else
    git "/var/#{repo}" do
        repository "git@github.com:#{git_account}/#{repo}.git"
        revision branch_name
        action :sync
        user "root"
    end
  end
  
  if repo.include? "-keys"
    if datacenter=="aws"
      bash "add_keys" do
        user "root"
        code <<-EOH
          cp /var/#{repo}/aws_* /etc/ec2
          chmod 600 /etc/ec2/aws_*
          touch /var/chef/cache/keys-#{repo}.lock
        EOH
        action :run
        #not_if {File.exists?("/var/chef/cache/keys-#{repo}.lock")}
      end
    end
  end
  
  
  if repo=="bootops"
    bash "add_devops_pythonpath_devops" do
      user "root"
      code <<-EOH
        echo "export PYTHONPATH=$PYTHONPATH:/var/#{repo}/classes" | tee -a /root/.bashrc
        source /root/.bashrc
        touch /var/chef/cache/pythonpath-#{repo}.lock
      EOH
      action :run
      not_if {File.exists?("/var/chef/cache/pythonpath-#{repo}.lock")}
    end
  end
  
end



