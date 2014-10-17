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


execute 'aptgetupdate' do
  command 'apt-get update'
end

%w{mysql-server apache2 libapache2-mod-wsgi python-pip python-mysqldb zip}.each do |pkg|
	package pkg
end

# 'package flask' wouldnt work, so this
execute "pip install Flask"
# not_if

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
# not_if
end

bash "installzip" do
#  user "www-data"
  cwd "/tmp"
  code <<-EOH
wget https://github.com/colincam/Awesome-Appliance-Repair/archive/master.zip
unzip master.zip
mv /tmp/Awesome-Appliance-Repair-master/AAR /var/www
  EOH
	not_if {::File.exists?("/tmp/master.zip")}
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
	# mode "0644"
	variables(
		:logger => node["logdir"]
		)
notifies :restart, "service[apache2]"
end

template "/var/www/AAR/AAR_config.py" do
	source "AAR_config.py.erb"
end


# password = node["password"]

# could just do this if no guard
# execute "mysql -u root  < \"/tmp/Awesome-Appliance-Repair-master/make_AARdb.sql\""
# But need to figure out the guard
execute "cratedb" do
	command "mysql -u root  < \"/tmp/Awesome-Appliance-Repair-master/make_AARdb.sql\""
    not_if  "mysql -u root -e 'show databases'|grep AARdb"
	action :run
end

execute "db1" do
	command "mysql -u root -e \"use AARdb\""
	# not_if
	action :run
end

# dbpassword = node["root_dbpswd"]
dbpassword = node["password"]

execute "db2" do
	command "mysql -u root -e  \"CREATE USER 'aarapp'@'localhost' IDENTIFIED BY '#{dbpassword}'\""
    not_if "mysql -u root -D mysql -e \"select user from user\"|grep aar"
	action :run
end

execute "db3" do
	command "mysql -u root -e  \"GRANT CREATE,INSERT,DELETE,UPDATE,SELECT on AARdb.* to aarapp@localhost\""
	# not_if
	action :run
end

package "curl"
