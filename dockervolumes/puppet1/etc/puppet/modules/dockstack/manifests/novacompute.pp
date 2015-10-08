class dockstack::novacompute (
) inherits dockstack::params {
  $ks_sql = join(["mysql://keystone:",$keystone_admin_password,"@",$vip_name,".",$domain,"/keystone"],'')
  $cinder_sql = join(["mysql://cinder:",$keystone_admin_password,"@",$vip_name,".",$domain,"/cinder"],'')
  $glance_sql = join(["mysql://glance:",$keystone_admin_password,"@",$vip_name,".",$domain,"/glance"],'')
  $nova_sql = join(["mysql://nova:",$keystone_admin_password,"@",$vip_name,".",$domain,"/nova"],'')
  $neutron_sql = join(["mysql://neutron:",$keystone_admin_password,"@",$vip_name,".",$domain,"/neutron"],'')
  $ks_public_endpoint = join(["http://",$vip_name,".",$domain,":5000/"],'')
  $ks_admin_endpoint = join(["http://",$vip_name,".",$domain,":35357/"],'')
  $auth_uri = join(["http://",$vip_name,".",$domain,":5000/v2.0"],'')
  $auth_url = join(["http://",$vip_name,".",$domain,":5000/v2.0"],'')
  $rabbit_host = $vip_name
  $control_server = join([$registered_control],"")
  $collector_server = "${vip_name}:8086"
  $glance_api_server = join([$vip_name,"9292"],":")
  $glance_endpoint = $vip_name
  $gateway = "192.168.1.48"

  class { 'nova':
    rabbit_hosts => [ "${vip_name}:5672" ],
  }

  class { 'nova::compute':
    enabled                 => true,
    vncserver_proxyclient_address => $::ipaddress,
  }

  class { 'nova::config':
    nova_config => {
      'keystone_authtoken/auth_uri'            => { value => $auth_uri},
      'keystone_authtoken/identity_uri'        => { value => $ks_admin_endpoint},
      'keystone_authtoken/admin_tenant_name'   => { value => 'services'},
      'keystone_authtoken/admin_user'          => { value => 'nova'},
      'keystone_authtoken/admin_password'      => { value => $keystone_admin_password},
      'DEFAULT/my_ip'                          => { value => $::ipaddress},
      'DEFAULT/vncserver_listen'               => { value => '0.0.0.0'},
      'DEFAULT/novncproxy_base_url'            => { value => 'http://vip:6080/vnc_auto.html'},
      'glance/host'                            => { value => 'vip'},
    }
  }

  file { [ "/opt/contrail/", "/opt/contrail/utils/","/opt/contrail/bin/" ]:
    ensure => "directory",
  }->
  file{ "/opt/contrail/bin/if-vhost0":
    mode   => 0760,
    owner  => root,
    group  => root,
    source => "puppet:///modules/dockstack/if-vhost0"
  }->
  file{ "/opt/contrail/bin/vrouter-functions.sh":
    mode   => 0760,
    owner  => root,
    group  => root,
    source => "puppet:///modules/dockstack/vrouter-functions.sh"
  }->

  file{ "/opt/contrail/utils/update_dev_net_config_files.py":
    mode   => 0660,
    owner  => root,
    group  => root,
    source => "puppet:///modules/dockstack/update_dev_net_config_files.py"
  }->
  contrail_vrouter_nodemgr_config { 
     'DISCOVERY/server':                           value => $vip_name;
  }->
  contrail_vrouter_agent_config {
       'DEFAULT/collectors':                         value => "${vip_name}:8086";
       'DEFAULT/agent_mode':                         value => "vrouter";
       'DISCOVERY/port':                             value => "5998";
       'DISCOVERY/server':                           value => $vip_name;
       'NETWORKS/control_network_ip':                value => $::ipaddress;
       'VIRTUAL-HOST-INTERFACE/name':                value => "vhost0";
       'VIRTUAL-HOST-INTERFACE/ip':                  value => "${::ipaddress}/24";
       'VIRTUAL-HOST-INTERFACE/gateway':             value => $gateway;
       'VIRTUAL-HOST-INTERFACE/physical_interface':  value => "eth0";
  }->
  class { 'contrail::vrouter::config':
    vhost_ip               => $::ipaddress,
    discovery_ip           => $vip_name,
    device                 => 'eth0',
    compute_device         => 'eth0',
    mask                   => '24',
    netmask                => '255.255.255.0',
    gateway                => '192.168.1.254',
    macaddr                => $::macaddress,
  }->
  exec { 'reload networking':
    command => '/sbin/ifdown -a && /sbin/ifup -a',
  }->
  exec { 'provision vrouter':
    command   => "/usr/bin/python /usr/share/contrail-utils/provision_vrouter.py --host_name ${::hostname}.${domain} --host_ip $::ipaddress --control_names $control_server --api_server_ip $vip_name --api_server_port 8082 --oper add --admin_user $keystone_admin_user --admin_password $keystone_admin_password --admin_tenant_name $keystone_admin_tenant",
  }
  
}
