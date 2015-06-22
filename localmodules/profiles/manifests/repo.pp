class profiles::repo {

    File {
        group   => 'root',
        owner   => 'root',
    }

    $sync_dependencies = ['createrepo','python-inotify','rsync']

    package { $sync_dependencies:
        ensure => installed,
    }

    file { '/usr/local/bin/create_repo_recursive.sh':
        source  => 'puppet:///modules/data/repo/create_repo_recursive.sh',
        mode    => '0755'
    }
    ~>
    exec { 'initial create_repo_recursive.sh run':
        command     => '/usr/local/bin/create_repo_recursive.sh /opt/repo /opt/local_repo',
        refreshonly => true,
        logoutput   => true,
        require     => [
            File['/usr/local/bin/create_repo_recursive.sh'],
            File['/opt/repo'],
            File['/opt/local_repo'],
            Package[$sync_dependencies],
        ],
        before      => File['/etc/yum.repos.d/local.repo'],
    }

    file { '/usr/local/bin/watcher.py':
        source  => 'puppet:///modules/data/repo/watcher.py',
        mode    => '0755',
        require => [
            File['/usr/local/bin/create_repo_recursive.sh'],
            Package[$sync_dependencies],
        ],
    }
    ->
    file { '/etc/watcher.ini':
        source  => 'puppet:///modules/data/repo/watcher.ini',
        mode    => '0755',
        notify  => Service['watcher'],
    }
    ->
    file { '/etc/systemd/system/watcher.service':
        source  => 'puppet:///modules/data/repo/watcher.service',
        mode    => '0755',
    }
    ~>
    service { 'watcher':
        ensure  => running,
        enable  => true,
        require => Package[$sync_dependencies],
    }

    class { '::nginx': }

    file { '/opt/repo':
        ensure => directory,
    }
    ->
    file { '/opt/local_repo':
        ensure => directory,
    }
    ->
    file { '/opt/local_repo/index.html':
        ensure  => present,
        content => 'Yum repo for App',
        notify  => Class['nginx::service'],
    }

    nginx::resource::vhost { 'local_repo':
        www_root => '/opt/local_repo',
    }

}
