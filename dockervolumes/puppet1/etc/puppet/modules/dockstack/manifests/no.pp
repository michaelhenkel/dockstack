class dockstack::no (
) inherits dockstack::params {
  $ks_sql = join(["mysql://keystone:",$keystone_admin_password,"@",$vip_name,".",$domain,"/keystone"],'')
  $cinder_sql = join(["mysql://cinder:",$keystone_admin_password,"@",$vip_name,".",$domain,"/cinder"],'')
  $glance_sql = join(["mysql://glance:",$keystone_admin_password,"@",$vip_name,".",$domain,"/glance"],'')
  $nova_sql = join(["mysql://nova:",$keystone_admin_password,"@",$vip_name,".",$domain,"/nova"],'')
  $neutron_sql = join(["mysql://neutron:",$keystone_admin_password,"@",$vip_name,".",$domain,"/neutron"],'')
  $ks_public_endpoint = join(["http://",$vip_name,".",$domain,":5000/"],'')
  $ks_admin_endpoint = join(["http://",$vip_name,".",$domain,":35357/"],'')
  $admin_auth_url = join(["http://",$vip_name,".",$domain,":35357/v2.0"],'')
  $auth_uri = join(["http://",$vip_name,".",$domain,":5000/v2.0"],'')
  $auth_url = join(["http://",$vip_name,".",$domain,":5000/v2.0"],'')
  $rabbit_host = $vip_name
  $glance_api_server = join([$vip_name,"9292"],":")
  $glance_endpoint = $vip_name

  class { 'nova':
    database_connection     => $nova_sql,
    rabbit_password         => 'guest',
    rabbit_host             => $rabbit_host,
    verbose                 => true,
    glance_api_servers      => $glance_api_server, 
  }->
  exec { 'restart-services':
    command   => '/usr/bin/supervisorctl restart all',
  }
  class { 'nova::api':
    enabled     => true,
    admin_password => $keystone_admin_password,
    auth_host      => $vip_name,
  }
  class { 'nova::network::neutron':
    neutron_admin_password     => $keystone_password,
    neutron_default_tenant_id  => "admin",
    neutron_url                => "http://${vip_name}:9696",
    neutron_admin_auth_url     => $admin_auth_url,
    network_api_class          => "nova_contrail_vif.contrailvif.ContrailNetworkAPI",
  }
  class { 'nova::config':
    nova_config => {
      'DEFAULT/vncserver_listen'              => { value => $::ipaddress},
      'DEFAULT/vncserver_proxyclient_address' => { value => $::ipaddress},
    }
  }
}
