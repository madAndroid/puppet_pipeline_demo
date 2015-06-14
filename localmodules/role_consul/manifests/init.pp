
class role_consul {

    class { '::firewall':
        ensure => 'stopped',
    }

#    class { 'consul':
#        config_hash => {
#            'datacenter'  => 'local-vagrant',
#            'data_dir'    => '/opt/consul',
#            'ui_dir'      => '/opt/consul/ui',
#            'client_addr' => '0.0.0.0',
#            'log_level'   => 'INFO',
#            'node_name'   => 'vagranthost',
#            'bootstrap'   => true,
#            'server'      => true
#        }
#    }

}
