server_type = node.name.split('-')[0]
slug = node.name.split('-')[1] 
datacenter = node.name.split('-')[2]
environment = node.name.split('-')[3]
location = node.name.split('-')[4]
cluster_slug = File.read("/var/cluster_slug.txt")
cluster_slug = cluster_slug.gsub(/\n/, "") 

data_bag("meta_data_bag")
git = data_bag_item("meta_data_bag", "git")
git_account = git["git_account"]
git_host = git["git_host"]

data_bag("server_data_bag")
this_data_bag = data_bag_item("server_data_bag", "#{server_type}")


package "git-core" do
  action :install
end

if node.chef_environment == "production"
    branch_name = "master"
    bootops_branch_name = "master"
else
    branch_name = node.chef_environment
    bootops_branch_name = "development"
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

  
  
  if repo=="bootops" 
    git "/var/#{repo}" do
        repository "git@bitbucket.org:davidmontgom/#{repo}.git"
        revision bootops_branch_name
        action :sync
        user "root"
    end
    bash "install bootops" do
      user "root"
      code <<-EOH
        cd /var/bootops
        /usr/bin/python setup.py install
      EOH
      action :run
    end
    
    

  else
    git "/var/#{repo}" do
        repository "#{git_host}:#{git_account}/#{repo}.git"
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



