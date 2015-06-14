
class role_jenkins_ci_server {

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

}
