class dockstack::ne (
) inherits dockstack::params {
  $ks_sql = join(["mysql://keystone:",$keystone_admin_password,"@",$vip_name,".",$domain,"/keystone"],'')
  $cinder_sql = join(["mysql://cinder:",$keystone_admin_password,"@",$vip_name,".",$domain,"/cinder"],'')
  $glance_sql = join(["mysql://glance:",$keystone_admin_password,"@",$vip_name,".",$domain,"/glance"],'')
  $nova_sql = join(["mysql://nova:",$keystone_admin_password,"@",$vip_name,".",$domain,"/nova"],'')
  $neutron_sql = join(["mysql://neutron:",$keystone_admin_password,"@",$vip_name,".",$domain,"/neutron"],'')
  $ks_public_endpoint = join(["http://",$vip_name,".",$domain,":5000/"],'')
  $ks_admin_endpoint = join(["http://",$vip_name,".",$domain,":35357/"],'')
  $auth_uri = join(["http://",$vip_name,".",$domain,":5000/v2.0"],'')
  $auth_url = join(["http://",$vip_name,".",$domain,":35357/v2.0"],'')
  $rabbit_host = $vip_name
  $glance_api_server = join([$vip_name,"9292"],":")
  $glance_endpoint = $vip_name

  class { 'neutron':
    enabled                 => true,
    rabbit_password         => 'guest',
    rabbit_user             => 'guest',
    rabbit_host             => $rabbit_host,
    verbose                 => true,
    core_plugin             => 'neutron_plugin_contrail.plugins.opencontrail.contrail_plugin.NeutronPluginContrailCoreV2',
    service_plugins         => [ 'neutron_plugin_contrail.plugins.opencontrail.loadbalancer.plugin.LoadBalancerPlugin' ],
    api_extensions_path     => [ 'extensions:/usr/lib/python2.7/dist-packages/neutron_plugin_contrail/extensions' ],
    notify                  => Service["supervisor-neutron-server"],
  }->
  exec { 'restart-services':
    command   => '/usr/bin/supervisorctl restart all',
  }
  class { 'neutron::plugins::opencontrail':
    api_server_ip              => $vip_name,
    api_server_port            => '8082',
    multi_tenancy              => true,
    contrail_extensions        => [ 'ipam:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_ipam.NeutronPluginContrailIpam',
                                    'policy:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_policy.NeutronPluginContrailPolicy',
                                    'route-table:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_vpc.NeutronPluginContrailVpc' ],
    keystone_auth_url          => $auth_url,
    keystone_admin_user        => 'admin',
    keystone_admin_tenant_name => 'admin',
    keystone_admin_password    => $keystone_admin_password,
    keystone_admin_token       => $keystone_admin_password,
    package_ensure             => 'present',
  }
  class { 'neutron::config':
    server_config  => {
       'keystone_authtoken/identity_uri'    =>  { value => $ks_admin_endpoint},
       'service_providers/service_provider' =>  { value => "LOADBALANCER:Opencontrail:neutron_plugin_contrail.plugins.opencontrail.loadbalancer.driver.OpencontrailLoadbalancerDriver:default"},
       'quotas/quota_network'                =>  { value => "-1"},
       'quotas/quota_subnet'                 =>  { value => "-1"},
       'quotas/quota_port'                   =>  { value => "-1"},
       'quotas/quota_driver'                 =>  { value => "neutron_plugin_contrail.plugins.opencontrail.quota.driver.QuotaDriver"},
    }
  }
       
                           
  class { 'neutron::server':
    database_connection     => $neutron_sql,
    auth_password           => $keystone_admin_password,
    #auth_host               => $vip_name,
    auth_uri                => $auth_uri,
    sync_db                 => true,
  }

  service { "supervisor-neutron-server":
    ensure   => running,
    start    => "supervisorctl -c /etc/supervisor/supervisor.conf start neutron-server",
    stop     => "supervisorctl -c /etc/supervisor/supervisor.conf stop neutron-server",
    restart  => "supervisorctl -c /etc/supervisor/supervisor.conf restart neutron-server",
    pattern  => "neutron-server"
  }
}
