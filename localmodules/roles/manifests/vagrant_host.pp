class roles::vagrant_host {

    include profiles::default
    include profiles::vagrant_host
    include profiles::repo

    Class['profiles::repo'] -> Class['profiles::default']
    Class['profiles::default'] -> Class['profiles::vagrant_host']

}
