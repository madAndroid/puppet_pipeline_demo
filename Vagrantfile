$bootstrap= <<SCRIPT
sudo iptables -F
sudo puppet resource yumrepo bashton baseurl='https://s3.amazonaws.com/bashton-yumrepo/el$releasever/' descr='Bashton repo' gpgcheck=0 enabled=1
sudo yum -y install wget unzip daemonize
SCRIPT

$consul_bootstrap= <<SCRIPT
cat <<EOF > /tmp/consul-bootstrap.pp
class { 'consul':
  config_hash => {
    'datacenter'  => 'local-vagrant',
    'data_dir'    => '/opt/consul',
    'ui_dir'      => '/opt/consul/ui',
    'client_addr' => '0.0.0.0',
    'log_level'   => 'INFO',
    'node_name'   => 'vagranthost',
    'bootstrap'   => true,
    'server'      => true
  }
}
EOF
puppet apply /tmp/consul-bootstrap.pp --modulepath=/vagrant/modules
SCRIPT

$consul_client= <<SCRIPT
[ -f /tmp/consul.zip ] || sudo wget -q https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip -O /tmp/consul.zip
[ -f /usr/local/bin/consul ] || sudo unzip /tmp/consul.zip -d /usr/local/bin/
[ -d /var/lib/consul/data ] || sudo mkdir -p /var/lib/consul/data
pgrep consul || sudo daemonize -p /var/run/consul.pid -o /var/lib/consul/consul.log \
  -e /var/lib/consul/consul.err -a /usr/local/bin/consul agent -dc=local-vagrant -data-dir /var/lib/consul/data/
sleep 3
/usr/local/bin/consul join 10.100.10.100
SCRIPT

jenkins_rpm = '/vagrant/jenkins-1.616-1.1.noarch.rpm'

$jenkins_bootstrap = <<script
  [ -f #{jenkins_rpm} ] && (rpm -q $(basename -s .rpm #{jenkins_rpm}) || rpm -i #{jenkins_rpm}) || true
script

boxes = [
  { name: :docker,  ip: '10.100.10.100', role: 'docker',  env: 'dev', memory: 4096 },
  { name: :jenkins, ip: '10.100.10.105', role: 'jenkins', env: 'dev' },
  { name: :webapp,  ip: '10.100.10.110', role: 'webapp',  env: 'dev' }
]

Vagrant.configure('2') do |config|

  config.ssh.forward_agent = true

  # VirtualBox Provider
  config.vm.provider :virtualbox do |virtualbox, override|
    config.ssh.insert_key = true
    virtualbox.customize ['modifyvm', :id, '--memory', '4096']
    override.vm.box = 'puppetlabs/centos-7.0-64-puppet'
    virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    virtualbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # Docker Provider
  config.vm.provider "docker" do |d|
    d.image = "bashtoni/centos7-vagrant"
    d.has_ssh = true
    d.create_args = [ "--privileged", "-v", "/sys/fs/cgroup:/sys/fs/cgroup:ro" ]
  end

  boxes.each do |box|

    primary = box[:name] == :docker ? true : false
    autostart = box[:name] == :docker ? true : false

    config.vm.define box[:name], primary: primary, autostart: autostart do |node|

      node.vm.network :private_network, ip: box[:ip]
      node.vm.hostname = "#{box[:name]}"
      node.vm.provision "shell", inline: "echo Provisioning node #{box[:name]}"
      node.vm.provision "shell", inline: $bootstrap, run: "always"

      if box[:name] == :jenkins
        node.vm.provision "shell", inline: $jenkins_bootstrap
        node.vm.network "forwarded_port", guest: 8082, host: 18082
      end

      if box[:name] == :docker
        node.vm.network "forwarded_port", guest: 18082, host: 8082
        node.vm.provision "shell", inline: $consul_bootstrap
      else
        node.vm.provision "shell", inline: $consul_client, run: "always"
      end

      node.vm.provision :puppet do |puppet|
        puppet.manifests_path     = 'manifests'
        puppet.manifest_file      = 'site.pp'
        puppet.module_path        = ["localmodules","modules"]
        puppet.hiera_config_path  = 'hiera.yaml'
        puppet.options            = '--verbose --show_diff'
        puppet.facter             = {
          "node_name" => "#{box[:name]}",
          "env"       => "#{box[:env]}",
          "location"  => "local",
          "role"      => "#{box[:role]}"
        }
      end

    end

  end

end
