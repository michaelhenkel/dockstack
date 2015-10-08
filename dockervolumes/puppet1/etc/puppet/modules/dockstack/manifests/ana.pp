class dockstack::ana (
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
       'KEYSTONE/admin_tenant_name'       : value => $keystone_admin_tenant;
       'KEYSTONE/insecure'                : value => 'false';
       'KEYSTONE/memcache_servers'        : value => '127.0.0.1:11211';
  }
  contrail_analytics_nodemgr_config {
       'DISCOVERY/server'                 : value => $vip_name;
       'DISCOVERY/port'                   : value => '5998';
  }
  contrail_analytics_api_config {
       'DEFAULTS/host_ip'                 : value => $::ipaddress;
       'DEFAULTS/collectors'              : value => $analytics_server;
       'DEFAULTS/cassandra_server_list'   : value => $cassandra_server_list;
       'DEFAULTS/http_server_port'        : value => '8090';
       'DEFAULTS/rest_api_port'           : value => '9081';
       'DEFAULTS/rest_api_ip'             : value => '0.0.0.0';
       'DISCOVERY/disc_server_ip'         : value => $vip_name;
       'DISCOVERY/disc_server_port'       : value => '5998';
       #'REDIS/server'                     : value => '127.0.0.1';
       'REDIS/redis_server_port'          : value => '6379';
       'REDIS/redis_query_port'           : value => '6379';
  }
  contrail_collector_config {
       'DEFAULT/hostip'                  : value => $::ipaddress;
       'DEFAULT/cassandra_server_list'   : value => $cassandra_server_list;
       #'DEFAULT/kafka_broker_list'       : value => $kafka_server_list;
       'COLLECTOR/port'                   : value => '8086';
       'DISCOVERY/server'                 : value => $vip_name;
       'REDIS/server'                     : value => '127.0.0.1';
       'REDIS/port'                       : value => '6379';
  }
  contrail_query_engine_config {
       'DEFAULT/hostip'                   : value => $::ipaddress;
       'DEFAULT/collectors'               : value => "${::ipaddress}:8086";
       'DEFAULT/cassandra_server_list'    : value => $cassandra_server_list;
       'REDIS/server'                     : value => '127.0.0.1';
       'REDIS/port'                       : value => '6379';
  }
  contrail_snmp_collector_config {
       'DEFAULTS/zookeeper'               : value => $zookeeper_server_list;
       'DISCOVERY/disc_server_ip'         : value => $vip_name;
       'DISCOVERY/disc_server_port'       : value => '5998';
  }
  contrail_topology_config {
       'DEFAULTS/zookeeper'               : value => $zookeeper_server_list;
  }
  #exec { 'restart-services':
  #  command   => '/sbin/restart supervisor-analytics',
  #}
  $ipaddressss=get_ip_addr('analytics1')
  $ip2="${ip1}"
  notify {"ip: $ipaddressss": }
  #$provision_command = "/usr/share/contrail-utils/provision_analytics_node.py --api_server_ip ${vip_name} --api_server_port 8082 --host_name ${::hostname} --host_ip ${::ipaddress} --oper add --admin_user ${keystone_admin_user} --admin_password ${keystone_admin_password} --admin_tenant ${keystone_admin_tenant}"
  #exec { 'provision-config':
  #  command   => $provision_command,
  #}
}
