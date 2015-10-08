class mymod::conf (
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
    $zookeeper_server_list = join($registered_cassandra,",")
    $cassandra_server_map = $registered_cassandra.map |$value| { join([$value,":9160"],"") }
    $cassandra_server_list = join($cassandra_server_map," ")
  }else{
    $cassandra_server_list = $registered_cassandra.map |$value| { join([$value,":9160"],"") }
    $zookeeper_server_list = $registered_cassandra
  }

  host { $::hostname:
    ip => $::ipaddress,
  }
  class { 'ntp':
     servers        => ['127.127.1.0'],
     fudge          => ['127.127.1.0 stratum 5'],
     service_manage => false,
  }
#  if ( size($registered_control) > 0 ) {
#    $control_map = $registered_control.map |$value| { join([$value,$value],":") }
#    $control_dns_map = $registered_control.map |$value| { join([$value,".dns:",$value,".dns"],"") }
#    $control_list = join($control_map,",")
#    $control_dns_list = join($control_dns_map,",")
#    class { 'contrail::config::config':
#      basicauthusers_property =>  [ $control_list,$control_dns_list ],
#    }
#  }
   class { 'contrail::config::config':
     basicauthusers_property =>  [ 
                                   'control1:control1',
                                   'control2:control2',
                                   'control3:control3',
                                   'control4:control4',
                                   'control5:control5',
                                   'control1.dns:control1.dns',
                                   'control2.dns:control2.dns',
                                   'control3.dns:control3.dns',
                                   'control4.dns:control4.dns',
                                  ]
     
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
  contrail_config_nodemgr_config {
       'DISCOVERY/server'                 : value => $vip_name;
       'DISCOVERY/port'                   : value => '5998';
  }
  contrail_api_config {
       'DEFAULTS/cassandra_server_list'   : value => $cassandra_server_list;
       'DEFAULTS/disc_server_ip'          : value => $vip_name;
       'DEFAULTS/ifmap_server_ip'         : value => $vip;
       'DEFAULTS/ifmap_server_port'       : value => '8443';
       'DEFAULTS/zk_server_ip'            : value => $zookeeper_server_list;
       'DEFAULTS/rabbit_server'           : value => $vip_name;
       'DEFAULTS/rabbit_port'             : value => '5672';
#       'KEYSTONE/auth_host'               : value => $vip_name;
#       'KEYSTONE/auth_protocol'           : value => 'http';
#       'KEYSTONE/auth_port'               : value => '35357';
#       'KEYSTONE/admin_user'              : value => $keystone_admin_user;
#       'KEYSTONE/admin_password'          : value => $keystone_admin_password;
#       'KEYSTONE/admin_token'             : value => $keystone_admin_token;
#       'KEYSTONE/admin_tenant_name'       : value => $keystone_admin_tenant;
  }
  contrail_device_manager_config {
       'DEFAULTS/cassandra_server_list'   : value => $cassandra_server_list;
       'DEFAULTS/api_server_ip'           : value => $vip_name;
       'DEFAULTS/disc_server_ip'          : value => $vip_name;
       'DEFAULTS/zk_server_ip'            : value => $zookeeper_server_list;
       'DEFAULTS/rabbit_server'           : value => $vip_name;
       'DEFAULTS/rabbit_port'             : value => '5672';
  }
  contrail_discovery_config {
       'DEFAULTS/zk_server_ip'            : value => $zookeeper_server_list;
       'DEFAULTS/cassandra_server_list'   : value => $cassandra_server_list;
  }
  contrail_schema_config {
       'DEFAULTS/ifmap_server_ip'         : value => $vip;
       'DEFAULTS/ifmap_server_port'       : value => '8443';
       'DEFAULTS/ifmap_username'          : value => 'schema-transformer';
       'DEFAULTS/ifmap_password'          : value => 'schema-transformer';
       'DEFAULTS/api_server_ip'           : value => $vip_name;
       'DEFAULTS/api_server_port'         : value => '8082';
       'DEFAULTS/zk_server_ip'            : value => $zookeeper_server_list;
       'DEFAULTS/cassandra_server_list'   : value => $cassandra_server_list;
       'DEFAULTS/disc_server_ip'          : value => $vip_name;
       'DEFAULTS/disc_server_port'        : value => '5998'
  }
  contrail_svc_monitor_config {
       'DEFAULTS/ifmap_server_ip'         : value => $vip;
       'DEFAULTS/ifmap_server_port'       : value => '8443';
       'DEFAULTS/ifmap_username'          : value => 'svc-monitor';
       'DEFAULTS/ifmap_password'          : value => 'svc-monitor';
       'DEFAULTS/api_server_ip'           : value => $vip_name;
       'DEFAULTS/api_server_port'         : value => '8082';
       'DEFAULTS/zk_server_ip'            : value => $zookeeper_server_list;
       'DEFAULTS/cassandra_server_list'   : value => $cassandra_server_list;
       'DEFAULTS/disc_server_ip'          : value => $vip_name;
       'DEFAULTS/disc_server_port'        : value => '5998';
       'DEFAULTS/rabbit_server'           : value => $vip_name;
       'DEFAULTS/rabbit_port'             : value => '5672';
       'SCHEDULER/analytics_server_ip'    : value => $vip_name;
       'SCHEDULER/analytics_server_port'  : value => '8081';
  }
#  exec { 'restart-services':
#    command   => '/usr/bin/supervisorctl -c /etc/supervisor/supervisord_config.conf restart all',
#  }
  exec { 'restart-redis':
    command   => '/usr/sbin/service redis-server restart'
  }
  exec { 'restart-ifmap':
    command   => '/usr/sbin/service ifmap-server restart'
  }
  exec { 'supervisor-config':
    command   => '/sbin/restart supervisor-config',
  }
  #$provision_config_command = "/usr/share/contrail-utils/provision_config_node.py --api_server_ip ${vip_name} --api_server_port 8082 --host_name ${::hostname} --host_ip ${::ipaddress} --oper add --admin_user ${keystone_admin_user} --admin_password ${keystone_admin_password} --admin_tenant ${keystone_admin_tenant}"
  #exec { 'provision-config':
  #  command   => $provision_config_command,
  #}
  #$provision_database_command = "/usr/share/contrail-utils/provision_config_node.py --api_server_ip ${vip_name} --api_server_port 8082 --host_name ${::hostname} --host_ip ${::ipaddress} --oper add --admin_user ${keystone_admin_user} --admin_password ${keystone_admin_password} --admin_tenant ${keystone_admin_tenant}"
  #exec { 'provision-config':
  #  command   => $provision_config_command,
  #}
}
