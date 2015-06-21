class profiles::webapp {

    class { '::firewall':
        ensure => 'stopped',
    }

    ### Configure vagranthost as a Jenkins slave, to facilitate Beaker tests:

    $jenkins = hiera_hash("jenkins", undef)

    if $jenkins != undef {

        $jenkins_ip = $jenkins['Node']['Address']

        user { 'jenkins-slave':
            ensure      => present,
            home        => '/home/jenkins-slave',
            managehome  => true,
        } ->
        class { 'jenkins::slave':
            executors         => '1',
            labels            => 'webapp',
            masterurl         => "http://${jenkins_ip}:8080",
            manage_slave_user => false,
        }

    } else {

        warning("Cannot setup Jenkins slave instance until master has been provisioned")

    }

}
