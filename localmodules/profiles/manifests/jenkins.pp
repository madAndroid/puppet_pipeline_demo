class profiles::jenkins {

    Exec {
        timeout     => '600',
    }

    class { '::jenkins': }
    class { '::nginx': }

    class { '::jenkins_job_builder':
        install_from_git  => true,
        git_url           => 'https://github.com/madAndroid/jenkins-job-builder.git',
    }

    ## Work around missing pip binary in CentOS7
    exec { 'python-pip-link':
        command => '/usr/sbin/alternatives --install /usr/bin/pip-python pip-python /usr/bin/pip 1',
        unless  => '/bin/test -e /usr/bin/pip-python',
        before  => Package['pyyaml'],
        require => Package['python-pip'],
    }
    ->
    Exec ['install_jenkins_job_builder']

    Yumrepo <| |> -> Package['python-pip']

    file { '/usr/local/bin/jenkins-jobs':
        target  => '/usr/bin/jenkins-jobs',
        ensure  => 'symlink',
    }
    ->
    Jenkins_job_builder::Job <| |>

    Jenkins::Plugin <| |> -> Jenkins_job_builder::Job <| |>

    ### curl against the jenkins api until we receive a 200
    exec { 'wait_for_Jenkins':
        command       => '/bin/sleep 30',
        tries         => 5,
        try_sleep     => 5,
        unless        => '/usr/bin/curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/api/json | grep 200',
        require       => Class['jenkins::service'],
    }

    Exec['wait_for_Jenkins'] -> Jenkins::Job <| |>
    Exec['wait_for_Jenkins'] -> Jenkins_job_builder::Job <| |>

}
