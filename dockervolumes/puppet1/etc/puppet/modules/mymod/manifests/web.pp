class mymod::web (
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
  $zookeeper_server = join([$::ipaddress,"2181"],":")
  $glance_endpoint = $vip_name
  $cassandra_ip = join($registered_cassandra,",")
  host { $::hostname:
    ip => $::ipaddress,
  }
  class { 'ntp':
     servers        => ['127.127.1.0'],
     fudge          => ['127.127.1.0 stratum 5'],
     service_manage => false,
  }
  #class { 'contrail::webui':
  #   openstack_vip   => $vip_name,
  #   contrail_vip    => $vip_name,
  #   cassandra_ip    => $registered_cassandra,
  #}
  class { 'contrail::webui::config': 
     openstack_vip   => $vip_name,
     contrail_vip    => $vip_name,
     cassandra_ip    => $registered_cassandra,
  }

  exec { 'stop-jobserver':
    command   => '/sbin/stop contrail-webui-jobserver',
  }->
  exec { 'stop-weberver':
    command   => '/sbin/stop contrail-webui-webserver',
  }->
  exec { 'start-jobserver':
    command   => '/sbin/start contrail-webui-jobserver',
  }->
  exec { 'start-weberver':
    command   => '/sbin/start contrail-webui-webserver',
  }
}
