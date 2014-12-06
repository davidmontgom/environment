
directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "0600"
  action :create
  not_if {File.exists?("/root/.ssh")}
end

=begin
cookbook_file "/root/.ssh/id_rsa_github" do
  source "id_rsa_github"
  mode 0600
  #not_if {File.exists?("/root/.ssh/id_rsa")}
end

cookbook_file "/root/.ssh/id_rsa_github.pub" do
  source "id_rsa_github.pub"
  mode 0600
  #not_if {File.exists?("/root/.ssh/id_rsa.pub")}
end
=end


cookbook_file "/root/.ssh/id_rsa_feed" do
  source "id_rsa_feed"
  mode 0600
  #not_if {File.exists?("/root/.ssh/id_rsa")}
end

cookbook_file "/root/.ssh/id_rsa_feed.pub" do
  source "id_rsa_feed.pub"
  mode 0600
  #not_if {File.exists?("/root/.ssh/id_rsa.pub")}
end


