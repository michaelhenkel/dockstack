class mymod::novacompute (
) inherits mymod::params {
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
  $glance_api_server = join([$vip_name,"9292"],":")
  $glance_endpoint = $vip_name

  class { 'nova':
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

  class { 'contrail::vrouter::config':
    vhost_ip               => $::ipaddress,
    discovery_ip           => $vip_name,
    device                 => 'eth0',
    compute_device         => 'eth0',
    mask                   => '24',
    netmask                => '255.255.255.0',
    gateway                => '192.168.1.254',
    macaddr                => $::macaddress,
    vrouter_agent_config   => {},
    vrouter_nodemgr_config => {},
  }
  
  
}
