#
# Cookbook Name:: arr
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#include_recipe "mysql::server"
#include_recipe "mysql::client"

#should use apt-get cookbook to do a 'sudo apt-get update'

execute 'aptgetupdate' do
  command 'apt-get update'
end

# %w{mysql-server apache2 libapache2-mod-wsgi python-pip python-mysqldb flask}.each do |pkg|
# 	package pkg 
# end

%w{mysql-server apache2 libapache2-mod-wsgi python-pip python-mysqldb zip}.each do |pkg|
	package pkg 
end

# 'package flask' wouldnt work, so this
execute "pip install Flask"

# Or is this best practice?
# execute 'installflask' do
#   command 'pip install Flask'
# end


service "apache2" do
	action [ :enable, :start ]
end
	

# Apparently this isnt recursive
directory "/var/www/AAR" do
	action :create
	owner "www-data"
	group "www-data"
	mode "0644"
end

# So need to do this
execute "chowndir" do
  command 'chown -R www-data:www-data /var/www/AAR'
end

bash "installzip" do
#  user "www-data"
  cwd "/var/www/AAR/"
  code <<-EOH
wget https://github.com/colincam/Awesome-Appliance-Repair/archive/master.zip
unzip master.zip
  EOH
	not_if {::File.exists?("/var/www/AAR/master.zip")}
end

	
execute "a2dissite default" do
  only_if do
    File.symlink?("/etc/apache2/sites-enabled/000-default")
  end
  notifies :restart, "service[apache2]"
end

logdir = node.default["logdir"]

template "/etc/apache2/sites-enabled/AAR-apache.conf" do
	source "AAR-apache.conf.erb"
	owner "www-data"
	group "www-data"
	mode "0644"
	# variable(
	# 	:logger => node["logdir"]
	# 	)
notifies :restart, "service[apache2]"
end

# template "/var/www/AAR/AAR_config.py" do
# 	source "AAR_config.py.erb"
# end

cookbook_file "/var/www/AAR/AAR_config.py" do
 	source "AAR_config.py"
 end

package "curl"



#Will this work?  Maybe use wget?
# deploy "/my/deploy/dir" do
# 	repo "https://github.com/colincam/Awesome-Appliance-Repair/archive/master.zip"
# 	# revision "abc123" # or "HEAD" or "TAG_for_1.0" or (subversion) "1234"
# 	# user "deploy_ninja"
# 	# enable_submodules true
# 	# migrate true
# 	deploy_to "/var/www/AAR"
# 	# migration_command "rake db:migrate"
# 	# environment "RAILS_ENV" => "production", "OTHER_ENV" => "foo"
# 	# shallow_clone true
# 	# action :deploy # or :rollback
# 	# restart_command "touch tmp/restart.txt"
# 	# git_ssh_wrapper "wrap-ssh4git.sh"
# 	scm_provider Chef::Provider::Git # is the default, for svn: Chef::Provider::Subversion
# end

