



user "chef-user" do
  supports :manage_home => true
  comment "Chef User"
  uid 1234
  gid "users"
  home "/home/chef-user"
  shell "/bin/bash"
  password "fu"
end