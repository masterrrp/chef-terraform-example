#
# Cookbook:: webserver
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe 'apt::default'

package 'apache2'

# Start and enable the apache2 service.
service 'apache2' do
  action [:enable, :start]
end

# Serve a custom home page.
file '/var/www/html/index.html' do
  content 'Hello world!... Terraform and Chef are awesome!!!'
end
