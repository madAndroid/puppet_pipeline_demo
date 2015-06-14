source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.6.0'
  gem "rspec", '< 3.2.0'
  gem "puppet-lint"
  gem "puppet-lint-indent-check"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem "hiera-puppet-helper", :git => 'https://github.com/bobtfish/hiera-puppet-helper.git'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end

group :system_tests do
  gem "beaker",
    :git => "https://github.com/madAndroid/beaker.git",
    :ref => 'BKR-314-idempotent-EL-install-release-repo'
  gem "beaker-rspec", '<= 4.0.0'
  gem "docker-api"
end
