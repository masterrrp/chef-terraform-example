# # encoding: utf-8

# Inspec test for recipe webserver::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# This is an example test, replace it with your own test.
describe port(80) do
  it { should be_listening }
end

# use basic tests
describe package('apache2') do
  it { should be_installed }
end

# extend tests with metadata
control 'apache2-1.0' do
  impact 1.0
  title 'apache2 service'
  desc 'Ensures apache2 service is up and running'
  describe service('apache2') do
    it { should be_enabled }
    it { should be_installed }
    it { should be_running }
  end
end

control "fileworld-1.0" do
  impact 1.0
  title "File Hello World"
  desc "Text should include the words 'hello world'."
  describe file('/var/www/html/index.html') do
   its('content') { should match 'Hello world!' }
  end
end

control "httpworld-1.0" do
  impact 1.0
  title "HTTP Hello World"
  desc "GET request should include the words 'hello world'."
  describe http('http://127.0.0.1:40080') do
    its('body') { should match /Hello world!/im }
  end
end
