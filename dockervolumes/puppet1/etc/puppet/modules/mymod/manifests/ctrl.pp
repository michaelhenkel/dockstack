class mymod::ctrl (
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
  if (size($registered_cassandra) > 1 ) {
    $zookeeper_server_map = $registered_cassandra.map |$value| { join([$value,":2181"],"") }
    $zookeeper_server_list = join($zookeeper_server_map,",")
    $cassandra_server_map = $registered_cassandra.map |$value| { join([$value,":9160"],"") }
    $cassandra_server_list = join($cassandra_server_map," ")
    $kafka_server_map = $registered_cassandra.map |$value| { join([$value,":9092"],"") }
    $kafka_server_list = join($kafka_server_map," ")
  }else{
    $zookeeper_server_list = $registered_cassandra.map |$value| { join([$value,":2181"],"") }
    $cassandra_server_list = $registered_cassandra.map |$value| { join([$value,":9160"],"") }
    $kafka_server_list = $registered_cassandra.map |$value| { join([$value,":9092"],"") }
  }
  $analytics_server = join([$::hostname,":8086"],"")
  host { $::hostname:
    ip => $::ipaddress,
  }
  $ifmap_user = $registered_control.map |$index,$value| { if($value==$::hostname) { join(["control",$index+1],"") } }
  $ifmap_dns_user = $registered_control.map |$index,$value| { if($value==$::hostname) { join(["control",$index+1,".dns"],"") } }
  class { 'ntp':
     servers        => ['127.127.1.0'],
     fudge          => ['127.127.1.0 stratum 5'],
     service_manage => false,
  }

  contrail_vnc_api_config {
      'auth/AUTHN_TYPE'        : value => 'keystone';
      'auth/AUTHN_PROTOCOL'    : value => 'http';
      'auth/AUTHN_SERVER'      : value => $vip_name;
      'auth/AUTHN_PORT'        : value => '35357';
      'auth/AUTHN_URL'         : value => '/v2.0/tokens';
  }

  contrail_keystone_auth_config {
       'KEYSTONE/auth_host'               : value => $vip_name;
       'KEYSTONE/auth_protocol'           : value => 'http';
       'KEYSTONE/auth_port'               : value => '35357';
       'KEYSTONE/admin_user'              : value => $keystone_admin_user;
       'KEYSTONE/admin_password'          : value => $keystone_admin_password;
       'KEYSTONE/admin_token'             : value => $keystone_admin_token;
       'KEYSTONE/admin_tenant_name'            : value => $keystone_admin_tenant;
       'KEYSTONE/insecure'                : value => 'false';
       'KEYSTONE/memcache_servers'        : value => '127.0.0.1:11211';
  }
  contrail_control_nodemgr_config {
       'DISCOVERY/server'                 : value => $vip_name;
       'DISCOVERY/port'                   : value => '5998';
  }
  contrail_dns_config {
       'DEFAULTS/hostip'                  : value => $::ipaddress;
       'DISCOVERY/server'                 : value => $vip_name;
       'IFMAP/password'                   : value => $ifmap_dns_user;
       'IFMAP/user'                       : value => $ifmap_dns_user;
  }
  contrail_control_config {
       'DEFAULT/hostip'                   : value => $::ipaddress;
       'DISCOVERY/server'                 : value => $vip_name;
       'IFMAP/password'                   : value => $ifmap_user;
       'IFMAP/user'                       : value => $ifmap_user;
  }
  exec { 'restart-services':
    command   => '/sbin/restart supervisor-control',
  }
#  $provision_command = "/usr/share/contrail-utils/provision_control.py --api_server_ip ${vip_name} --api_server_port 8082 --host_name ${::hostname} --host_ip ${::ipaddress} --router_asn 64512 --oper add --admin_user ${keystone_admin_user} --admin_password ${keystone_admin_password} --admin_tenant ${keystone_admin_tenant}"
#  exec { 'provision-config':
#    command   => $provision_command,
#  }
}
