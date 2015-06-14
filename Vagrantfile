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
/usr/local/bin/consul join 10.100.10.10
SCRIPT

Vagrant.configure('2') do |config|

  config.ssh.forward_agent = true

  # VirtualBox Provider
  config.vm.provider :virtualbox do |virtualbox, override|
    config.ssh.insert_key = true
    virtualbox.customize ['modifyvm', :id, '--memory', '4096']
    config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ['.vagrant/', '.git/']
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

  vagrant_host_provision = {
    manifests_path: 'manifests',
    manifest_file: 'site.pp',
    module_path: ["localmodules","modules"],
    hiera_config_path: 'hiera.yaml',
    options: '--verbose --show_diff',
    facter: {
      "location"  => "local",
      "env"       => "dev",
      "role"      => "vagrant_host",
    },
  }

  # Vagrant Docker Host
  config.vm.define "host", primary: true do |vagrant|
    vagrant.vm.hostname = "vagranthost"
    vagrant.vm.network "private_network", ip: "10.100.10.10"
    vagrant.vm.network "forwarded_port", guest: 18082, host: 8082
    vagrant.vm.provision "shell", inline: $consul_bootstrap
    vagrant.vm.provision "shell", inline: $bootstrap
    vagrant.vm.provision "puppet", vagrant_host_provision
    vagrant.vm.provision "shell", inline: "cd /vagrant && vagrant up jenkins --provider=docker && vagrant provision jenkins"
    vagrant.vm.provision "puppet", vagrant_host_provision
  end

  # Docker Jenkins container
  config.vm.define "jenkins", autostart: false do |jenkins|
    jenkins.vm.hostname = "jenkins"
    jenkins.vm.network "forwarded_port", guest: 8082, host: 18082
    jenkins.vm.provision "shell", inline: $bootstrap
    jenkins.vm.provision "shell", inline: $consul_client,
      run: "always"
    jenkins.vm.provision "puppet",
      manifests_path: 'manifests',
      manifest_file: 'site.pp',
      options: '--verbose --show_diff',
      module_path: ["localmodules","modules"],
      hiera_config_path: 'hiera.yaml',
      facter: {
        "location"  => "local",
        "env"       => "dev",
        "role"      => "jenkins_ci_server",
      }
  end

end
