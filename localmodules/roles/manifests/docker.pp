class roles::docker {

    include profiles::default
    include profiles::docker
    include profiles::repo

    Class['profiles::repo'] -> Class['profiles::default']
    Class['profiles::default'] -> Class['profiles::docker']

}
