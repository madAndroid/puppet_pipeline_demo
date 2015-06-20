class profiles::consul {

    class { '::firewall':
        ensure => 'stopped',
    }

    class { '::consul':
        config_hash => {
            'bootstrap_expect' => 1,
            'data_dir'         => '/opt/consul',
            'client_addr'      => '0.0.0.0',
            'datacenter'       => 'local',
            'log_level'        => 'INFO',
            'node_name'        => $::hostname,
            'bind_addr'        => $::ipaddress_enp0s8,
            'server'           => true,
            'ui_dir'           => '/opt/consul/ui',
        }
    }

}
