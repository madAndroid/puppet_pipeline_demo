class roles::webapp {

    include profiles::default
    include profiles::webapp

    Class['profiles::default'] -> Class['profiles::webapp']

}
