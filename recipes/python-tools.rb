

package "python-dev" do
  action :install
end

package "libffi-dev" do
  action :install
end

package "libssl-dev" do
  action :install
end


package "python3-pip" do
  action :install
end


bash "install_python2_pip" do
  cwd "/tmp/"
  code <<-EOH
  wget https://bootstrap.pypa.io/get-pip.py
  /usr/bin/python2.7 get-pip.py
EOH
  creates "#{Chef::Config[:file_cache_path]}/get-pip.lock"
  not_if {File.exists?("#{Chef::Config[:file_cache_path]}/get-pip.lock")}
end

bash "install_python2_setuptools" do
  code <<-EOH
  	pip install --upgrade setuptools
  EOH
end