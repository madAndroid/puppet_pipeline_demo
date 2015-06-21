require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'


RSpec.configure do |c|

  # Readable test descriptions
  c.formatter = :documentation
  c.color = true
  c.tty = true

  # Configure all nodes in nodeset
  c.before :suite do

    hosts.each do |host|

      install_puppet(:version => ENV['PUPPET_VERSION'] || '3.6.0')

      upload_ssh_config(host)
      upload_fixture_files(host)
      upload_fixture_templates(host)

      upload_hiera_config(host)

      ## Upload hiera data directory
      hiera_data_dir = host['hieradata_dir'] || "hieradata"
      scp_to host, "#{project_root}/#{hiera_data_dir}", "/etc/puppet" if File.exists?("#{project_root}/#{hiera_data_dir}")

      ## Install build dependencies:
      on host, "yum install -y tar gcc ruby-devel git"

      ## Discover our ruby version, so we can pin librarian puppet, if required:
      rubyversion = on( host, facter('rubyversion')).stdout.strip
      if rubyversion == '1.8.7'
        on host, "gem list | grep highline | grep '1.6.1' || gem install highline -v 1.6.1"
        lp_version = "-v 1.0.4"
      end

      ## Push Puppetfile{,.lock} to target host
      upload_puppetfile(host)

      ## We manage module installation using librarian-puppet
      on host, "gem list | grep librarian-puppet || gem install librarian-puppet #{lp_version}"
      on host, "cd /etc/puppet && librarian-puppet install --verbose"

      ## Set facts defined in nodeset
      set_facts(host, host['facter'])

      ## Upload our local modules
      scp_to host, "#{project_root}/localmodules", "/etc/puppet"

      ## Run any bootstrap commands we may have configured in nodeset YAML:
      host['bootstrap_commands'].each do |provision|
        on host, provision
      end unless host['bootstrap_commands'].nil?

    end

  end
end

### Helper methods
def upload_ssh_config(host)

  ssh_config = <<-EOF.gsub(/^ +/,"")
  Host github.com
  ForwardAgent yes
  StrictHostKeyChecking=no
  UserKnownHostsFile=/dev/null
  EOF
  create_remote_file( host, "/root/.ssh/config", ssh_config )

end

def upload_hiera_config(host, hiera_config_file=nil)

  hiera_config = {
    :backends => [ 'yaml' ],
    :hierarchy => [
      "%{fqdn}/%{calling_module}",
      "%{calling_module}",
      "common"
    ],
    :yaml => {
      :datadir => '/etc/puppet/hieradata'
    }
  }

  if hiera_config_file.nil?
    if File.exists?("#{project_root}/hiera.yaml")
      hiera_config = YAML::load(File.open("#{project_root}/hiera.yaml"))
      hiera_config[:yaml][:datadir] = '/etc/puppet/hieradata'
      create_remote_file( host, "/etc/puppet/hiera.yaml", hiera_config.to_yaml )
    else
      create_remote_file( host, "/etc/puppet/hiera.yaml", hiera_config.to_yaml )
    end
  elsif File.exists?("#{project_root}/#{hiera_config_file}")
    scp_to host, "#{project_root}/#{hiera_config_file}", "/etc/puppet/hiera.yaml"
  else
    raise "Could not find hiera_config_file: #{hiera_config_file}"
  end

end

def upload_fixture_files(host)

  on host, "mkdir -p /etc/puppet/files"
  scp_to host, "#{project_root}/spec/fixtures/files", "/etc/puppet/" if File.exists?("#{project_root}/spec/fixtures/files")

end

def upload_fixture_templates(host)

  on host, "mkdir -p /etc/puppet/templates"
  scp_to host, "#{project_root}/spec/fixtures/templates", "/etc/puppet/" if File.exists?("#{project_root}/spec/fixtures/templates")

end

def upload_hiera_yaml( hiera_content, calling_module='puppet_pipeline' )

  require 'yaml'

  hosts.each do |host|
    on host, "mkdir -p /etc/puppet/hieradata"
    if hiera_content.respond_to?(:to_hash)
      create_remote_file( host, "/etc/puppet/hieradata/#{calling_module}.yaml", hiera_content.to_yaml )
    else
      file_to_upload = File.expand_path(File.join(File.dirname(__FILE__), '..', "spec/fixtures/hieradata/#{hiera_content}.yaml"))
      if File.exists?( file_to_upload )
        scp_to host, file_to_upload, "/etc/puppet/hieradata/#{calling_module}.yaml"
      end
    end
  end

end


def upload_puppetfile(host)

  require 'yaml'

  static_puppetfile = File.expand_path(File.join(project_root, 'Puppetfile'))
  puppetfile_lock = File.expand_path(File.join(project_root, 'Puppetfile.lock'))
  template_puppetfile = File.expand_path(File.join(project_root, 'Puppetfile.erb'))
  fixtures_file = File.expand_path(File.join( project_root, '.fixtures.yml' ))

  if File.exists?( template_puppetfile )

    if File.exists?( fixtures_file )
      fixtures_hash = YAML::load(File.open( fixtures_file ))

      repositories = fixtures_hash['fixtures']['repositories']
      forge_modules = fixtures_hash['fixtures']['forge_modules']

      template = ERB.new( File.read( template_puppetfile ), 0, '<>' )
      puppetfile = template.result(binding)
      create_remote_file( host, "/etc/puppet/Puppetfile", puppetfile )
    else
      raise "Cannot find .fixtures.yml at #{fixtures_file}!"
    end

  elsif File.exists?( static_puppetfile )
    scp_to host, static_puppetfile, "/etc/puppet/Puppetfile"
    if File.exists?( puppetfile_lock )
      scp_to host, puppetfile_lock, "/etc/puppet/Puppetfile.lock"
    end
  else
    raise "Cannot find Puppetfile or Puppetfile.erb!"
  end

end

def set_facts(host, facter)

  unless facter.nil?
    ### Convert our Beaker object hash into a regular ruby hash:
    facter_hash = facter.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
    require 'yaml'
    on host, "mkdir -p /etc/facter/facts.d"
    create_remote_file( host, "/etc/facter/facts.d/beaker.yaml", facter_hash.to_yaml)
  end

end

def project_root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

## Shared contexts
shared_context "hieradata_common" do
  upload_hiera_yaml('common', 'common')
end
