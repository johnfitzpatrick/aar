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
  cwd "/tmp"
  code <<-EOH
wget https://github.com/colincam/Awesome-Appliance-Repair/archive/master.zip
unzip master.zip
mv /tmp/Awesome-Appliance-Repair-master/AAR /var/www
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

execute "cratedb" do
	command "mysql -u root  < \"/tmp/Awesome-Appliance-Repair-master/make_AARdb.sql\""
    # not_if {::File.exists?("AARdb")}  how to chk DB exists????
	action :run
end

# mysql -u root  < "make_AARdb.sql"

execute "db1" do
	# command "mysql -u root -proot_dbpswd -D mysql -r -B -N -e \"use AARdb\""
	command "mysql -u root -e \"use AARdb\""
	action :run
end

dbpassword = node["root_dbpswd"]

execute "db2" do
	# command "mysql -u root -p#{password} -D mysql -r -B -N -e \"CREATE USER 'aarapp'@'localhost'\""
	command "mysql -u root -e  \"CREATE USER 'aarapp'@'localhost' IDENTIFIED BY '#{dbpassword}'\""
    # not_if {::File.exists?("aarapp")}  how to chk user exists????
	action :run
end

execute "db3" do
	# command "mysql -u root -p#{password} -D mysql -r -B -N -e \"GRANT CREATE,INSERT,DELETE,UPDATE,SELECT on AARdb.* to aarapp@localhost\""
	command "mysql -u root -e  \"GRANT CREATE,INSERT,DELETE,UPDATE,SELECT on AARdb.* to aarapp@localhost\""
	action :run
end

package "curl"

# mysql -u root -e "DROP DATABASE AARdb"



