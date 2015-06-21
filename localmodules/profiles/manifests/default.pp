class profiles::default {

    $gem_packages = hiera_array('gem_packages')
    $rpm_packages = hiera_array('rpm_packages')

    class { '::epel': 
        epel_baseurl => "http://mirror.bytemark.co.uk/fedora/epel/7/x86_64/"
    }->
    package { $rpm_packages:
        ensure => installed,
    }->
    package { $gem_packages:
        ensure   => installed,
        provider => 'gem',
        require  => Package['ruby-devel','gcc','make'],
    }

    class { '::sudo': }

    create_resources('sudo::conf', hiera_hash('sudoconf'))

#    if $role != 'consul' {
#
#        class { '::consul':
#            config_hash => {
#                'datacenter'  => 'local-vagrant',
#                'data_dir'    => '/opt/consul',
#                'ui_dir'      => '/opt/consul/ui',
#                'client_addr' => '0.0.0.0',
#                'log_level'   => 'INFO',
#                'node_name'   => 'vagranthost',
#                'bootstrap'   => true,
#                'server'      => true
#            }
#        }
#
#    }

    if $role == 'vagrant_host' {
        $repo_requires = Class['profiles::repo']
    }

    ## Local repo config:
    file { '/etc/yum.repos.d/local.repo':
        content   => hiera('local_repo_config'),
        require   => $repo_requires
    }

}
