class profiles::docker {

    class { '::firewall':
        ensure => 'stopped',
    }

    group { "docker":
            ensure => present,
            gid    => 31337
    }->
    user { "docker":
        ensure     => present,
        gid        => "docker",
        groups     => ["wheel", "docker", "root"],
        shell      => "/bin/bash",
        require    => Group["docker"]
    }->
    package { ['docker','device-mapper-libs']:
        ensure => latest,
    } ~>
    service { 'docker':
        ensure  => running,
        enable  => true,
    } ->
    package { 'vagrant':
        ensure   => installed,
        provider => rpm,
        source   => 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.rpm',
    } ->
    user { 'vagrant':
        ensure => present,
        groups => ['docker'],
    }

    ### Configure vagranthost as a Jenkins slave, to facilitate Beaker tests:

    $jenkins = hiera_hash("jenkins", undef)

    if $jenkins != undef {

        $jenkins_ip = $jenkins['Node']['Address']

        user { 'jenkins-slave':
            ensure      => present,
            groups      => ['docker'],
            home        => '/home/jenkins-slave',
            managehome  => true,
        } ->
        class { 'jenkins::slave':
            executors         => '4',
            labels            => 'docker centos7',
            masterurl         => "http://${jenkins_ip}:8080",
            manage_slave_user => false,
        }

        file {[
            '/var/tmp/jenkins-docker',
            '/var/tmp/jenkins-docker/centos7',
            ]:
            ensure  => directory,
        }

        file { '/var/tmp/jenkins-docker/centos7/Dockerfile':
            source  => "puppet:///modules/data/jenkins/centos7-Dockerfile",
            owner   => $::jenkins::slave::slave_user,
            group   => $::jenkins::slave::slave_user,
        }->
        docker::image { 'beaker-centos7':
            image_tag   => 'latest',
            docker_file => '/var/tmp/jenkins-docker/centos7/Dockerfile',
        }

    } else {

        warning("Cannot setup Jenkins slave instance until master has been provisioned")

    }

}
