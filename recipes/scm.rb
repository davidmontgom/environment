data_bag("my_data_bag")
db = data_bag_item("my_data_bag", "my")

#git_username = db['git']['Username']
#git_password = db['git']['Password']
#git_name = db['git']['Name']
#git_email = db['git']['Email']
git_account = db['git']['Account']

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


git_repos = node['environment']['git_repos'] 
git_repos.each do |repo|

  execute "git_stash" do
    cwd "/var/#{repo}"
    command "git stash"
    action :run
    only_if {File.exists?("/var/#{repo}")}
  end

  git "/var/#{repo}" do
      repository "git@github.com:#{git_account}/#{repo}.git"
      revision branch_name
      action :sync
      user "root"
  end
  
  if repo.include? "-devops"
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
  
  if repo.include? "-fabric"
    bash "add_devops_pythonpath_fabric" do
      user "root"
      code <<-EOH
        echo "export PYTHONPATH=$PYTHONPATH:/var/#{repo}" | tee -a /root/.bashrc
        source /root/.bashrc
        touch /var/chef/cache/pythonpath-#{repo}.lock
      EOH
      action :run
      not_if {File.exists?("/var/chef/cache/pythonpath-#{repo}.lock")}
    end
  end
  
  if repo.include? "-settings"
    bash "add_devops_pythonpath_settings" do
      user "root"
      code <<-EOH
        echo "export PYTHONPATH=$PYTHONPATH:/var/#{repo}" | tee -a /root/.bashrc
        source /root/.bashrc
        touch /var/chef/cache/pythonpath-#{repo}.lock
      EOH
      action :run
      not_if {File.exists?("/var/chef/cache/pythonpath-#{repo}.lock")}
    end
  end

end





















