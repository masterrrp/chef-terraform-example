#
# Cookbook:: webserver
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'webserver::default' do
  context 'When all attributes are default, on an Ubuntu 14.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04')
      runner.converge(described_recipe)
    end

    it 'install apache2 package' do
      expect(chef_run).to install_package('apache2')
    end

    it 'enable apache2 service' do
      expect(chef_run).to enable_service('apache2')
    end

    it 'start apache2 service' do
      expect(chef_run).to start_service('apache2')
    end

    it 'server a web page that says "Hello world!"' do
      expect(chef_run).to render_file('/var/www/html/index.html').with_content(/Hello world!./im)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
