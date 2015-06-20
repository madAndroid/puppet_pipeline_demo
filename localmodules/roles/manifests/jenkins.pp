class roles::jenkins {

    include profiles::default
    include profiles::jenkins

    Class['profiles::default'] -> Class['profiles::jenkins']

}
