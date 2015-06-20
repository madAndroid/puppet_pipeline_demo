#!/usr/bin/env ruby
#^syntax detection

forge "https://forgeapi.puppetlabs.com"

# use dependencies defined in metadata.json
#metadata

# use dependencies defined in Modulefile
# modulefile

# A module from the Puppet Forge
mod 'puppetlabs/stdlib'
mod 'puppetlabs/firewall'
mod 'rtyler/jenkins'
mod 'jfryman/nginx', '0.2.6'
mod 'puppetlabs/inifile', '1.2.0'
mod 'puppetlabs/vcsrepo', '1.3.0'

mod 'stahnma/epel'
mod 'garethr/docker'

mod 'puppet/jenkins_job_builder',
    :git => "https://github.com/madAndroid/puppet-jenkins_job_builder.git",
    :ref => 'install_from_git'

mod 'puppetlabs/vcsrepo',
  :git => "https://github.com/puppetlabs/puppetlabs-vcsrepo.git"

mod 'lynxman/hiera_consul'
mod 'KyleAnderson/consul', 
  :git => 'https://github.com/bashtoni/puppet-consul.git'

# A module from git
# mod 'puppetlabs-ntp',
#   :git => 'git://github.com/puppetlabs/puppetlabs-ntp.git'

# A module from a git branch/tag
# mod 'puppetlabs-apt',
#   :git => 'https://github.com/puppetlabs/puppetlabs-apt.git',
#   :ref => '1.4.x'

# A module from Github pre-packaged tarball
# mod 'puppetlabs-apache', '0.6.0', :github_tarball => 'puppetlabs/puppetlabs-apache'
