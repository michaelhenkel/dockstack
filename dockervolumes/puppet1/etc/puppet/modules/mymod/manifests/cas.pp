class mymod::cas (
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

  host { $::hostname:
    ip => $::ipaddress,
  }
  class { 'ntp':
     servers        => ['127.127.1.0'],
     fudge          => ['127.127.1.0 stratum 5'],
     service_manage => false,
  }
  class { 'zookeeper':
    servers      => $registered_cassandra,
  }
  group { "kafka":
        ensure => present,
  }
  user { "kafka":
        ensure     => present,
        gid        => "kafka",
        membership => minimum,
        shell      => "/bin/bash",
        require    => Group["kafka"]
  }
  class { 'kafka::broker':
    config          => { 'client.id' => '0', 'zookeeper.connect' => $zookeeper_server },
    install_java    => false,
    service_restart => false
  }
  class { 'contrail::database':
  }
  class {'::cassandra':
    seeds        => $registered_cassandra,
    seed_address => $::ipaddress,
  } 
  contrail_database_nodemgr_config {
       'DISCOVERY/server'        : value => $vip_name;
       'DISCOVERY/port'          : value => '5998';
       'DEFAULT/hostip'          : value => $::ipaddress;
       'DEFAULT/minimum_diskGB'  : value => '20';
  }
  #service { "zookeeper":
  #  ensure => running,
  #}
}
