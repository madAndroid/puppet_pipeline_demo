
class defaults {

    $gem_packages = hiera_array('gem_packages')
    $rpm_packages = hiera_array('rpm_packages')

    class { '::epel': 
        epel_baseurl => "http://mirror.bytemark.co.uk/fedora/epel/7/x86_64/"
    }->
    package { $rpm_packages:
        ensure => installed,
    }->
    package { $gem_packages:
        ensure   => installed,
        provider => 'gem',
        require  => Package['ruby-devel','gcc','make'],
    }

}
