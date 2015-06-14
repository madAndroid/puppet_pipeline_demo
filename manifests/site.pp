node default {

    if(!$env) {
      fail("environment fact not set")
    }

    if(!$role) {
      fail("role fact not set")
    }

    if(!$location) {
      fail("role fact not set")
    }

    notice("Location    : ${location}"   )
    notice("Environment : ${env}"        )
    notice("Role        : ${role}"       )

    stage { 'initial':
        before => Stage['main'],
    }

    class { 'defaults':
        stage => initial,
    }

    # Dispatch to the role-specific class
    class { "role_${role}": }

    if versioncmp($::puppetversion, '3.6.2') >= 0 {
        Package {
            allow_virtual => false,
        }
    }

}
