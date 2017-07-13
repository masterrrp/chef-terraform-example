# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
user                     "#{ENV['CHEF_CLIENT_NAME']}"
node_name                "#{ENV['CHEF_CLIENT_NAME']}"
client_key               "#{current_dir}/#{user}.pem"
chef_server_url          "#{ENV['CHEF_SERVER_URL']}"
cookbook_path            ["#{current_dir}/../cookbooks"]
