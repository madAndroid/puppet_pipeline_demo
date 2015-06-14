require 'spec_helper_acceptance'

describe 'puppet_pipeline class' do

  include_context "hieradata_common"

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do

      manifest = File.open("#{project_root}/manifests/site.pp", "rb")
      pp = manifest.read

      apply_opts = {
        :catch_failures => true,
        :debug => ENV['BEAKER_puppet_debug'],
        :modulepath => '/etc/puppet/modules:/etc/puppet/localmodules'
      }

      # Run it twice and test for idempotency
      hosts.each do |host|
        expect(apply_manifest_on(host, pp, apply_opts ).exit_code).to_not eq(1)
        expect(apply_manifest_on(host, pp, apply_opts ).exit_code).to be_zero
      end

    end

  end

  describe 'jenkins node' do

      hosts.each do |host|
          if host['roles'].include?('jenkins')
              %w(jenkins nginx).each do |dep|
                  describe package(dep), :node => host do
                      it { is_expected.to be_installed }
                  end
                  describe service(dep), :node => host do
                      it { is_expected.to be_enabled }
                      it { is_expected.to be_running }
                  end
              end
          end
      end

  end

end
