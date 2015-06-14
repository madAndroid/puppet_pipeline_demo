require 'puppetlabs_spec_helper/module_spec_helper'
require 'hiera-puppet-helper'
require 'yaml'

begin
  require 'fixtures/modules/module_data/lib/hiera/backend/module_data_backend.rb'
rescue LoadError
  raise "could not load module_data_backend - make sure spec_prepare has been run"
end

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
project_root = File.expand_path(File.join(__FILE__, '..', '..'))
hiera_config = YAML.load_file(File.join(project_root, "hiera.yaml"))

# Add fixture lib dirs to LOAD_PATH. Work-around for PUP-3336
if Puppet.version < "4.0.0"
  Dir["#{fixture_path}/modules/*/lib"].entries.each do |lib_dir|
    $LOAD_PATH << lib_dir
  end
end

RSpec.configure do |c|
  c.formatter = :documentation
  # Enable colour in Jenkins
  c.color = true
  c.tty = true
  c.module_path = 'modules:localmodules'
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)

    if ENV['RSPEC_PUPPET_DEBUG']
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
    end

  end
end

# use both rpsec and yaml backends .. see: https://github.com/bobtfish/hiera-puppet-helper#advanced
shared_context "hieradata" do
  let(:hiera_config) do
    { :backends => ['rspec', 'yaml', 'module_data'],
    :hierarchy => hiera_config[:hierarchy],
    :yaml => {
      :datadir => File.join(project_root, 'hieradata') },
    :rspec => respond_to?(:hiera_data) ? hiera_data : {} }
  end
end

shared_context "facter" do
  let(:default_facts) {{
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :concat_basedir => '/dne',
    :operatingsystem => 'CentOS',
    :architecture => 'x86_64',
    :cache_bust => Time.now,
  }}
end
