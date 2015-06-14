require 'spec_helper'

describe 'role_jenkins_ci_server', :type => 'class' do

    def self.test_standard_behaviour

        # These tests get run in both Debian and RedHat contexts
        #  later on.  Specify any cross-distribution behaviour here.

        it { should compile.with_all_deps }

        it { should contain_class('role_jenkins_ci_server') }
        it { should contain_class('jenkins') }
        it { should contain_class('nginx') }

    end

    # Now we test specific contexts:
    describe "on a RedHat OS" do

        include_context "hieradata"
        include_context "facter"

        let(:facts) do
            default_facts.merge({
                :operatingsystemmajrelease => '7',
                :operatingsystemrelease => '7.0',
                :location => 'local',
                :role => 'jenkins_ci_server',
                :env => 'dev',
                :path => '/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin',
            })
        end

        context "With default parameters" do
            test_standard_behaviour
        end

        %w(jenkins nginx).each do |dep|
            it { should contain_package(dep) }
            it { should contain_service(dep).with(
                'ensure'    => 'running',
                'enable'    => 'true',
            )}
        end

    end

end
