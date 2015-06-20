class roles::consul {

    include profiles::default
    include profiles::consul

    Class['profiles::default'] -> Class['profiles::consul']

}
