class mymod::params (
){
  $common                       = hiera("common")
  $vip                          = $common['vip']
  $vip_mask                     = $common['vip_mask']
  $vip_name                     = $common['vip_name']
  $domain                       = $common['domain']
  $keystone_admin_user          = $common['keystone_admin_user']
  $keystone_admin_tenant        = $common['keystone_admin_tenant']
  $keystone_admin_password      = $common['keystone_admin_password']
  $keystone_admin_token         = $common['keystone_admin_token']
  $haproxy_user                 = $common['haproxy_user']
  $haproxy_password             = $common['haproxy_password']
  $galera_password		= $common['galera_password']

  $registered_services          = hiera("registered_services")
  $registered_haproxy           = $registered_services['haproxy']
  $registered_galera            = $registered_services['galera']
  $registered_rabbitmq          = $registered_services['rabbitmq']
  $registered_keystone          = $registered_services['keystone']
  $registered_glance            = $registered_services['glance']
  $registered_cinder            = $registered_services['cinder']
  $registered_nova              = $registered_services['nova']
  $registered_neutron           = $registered_services['neutron']
  $registered_dashboard         = $registered_services['dashboard']
  $registered_redis             = $registered_services['redis']
  $registered_openstack         = $registered_services['openstack']
  $registered_cassandra         = $registered_services['cassandra']
  $registered_config            = $registered_services['config']
  $registered_control           = $registered_services['control']
  $registered_webui             = $registered_services['webui']
  $registered_analytics         = $registered_services['analytics']
}
