class dockstack::ci (
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
  $glance_endpoint = $vip_name

  class { 'cinder':
    database_connection     => $cinder_sql,
    rabbit_password         => 'guest',
    rabbit_host             => $rabbit_host,
    verbose                 => true,
  }

  class { 'cinder::api':
    keystone_password   => $keystone_admin_password,
    keystone_auth_host  => $vip_name,
    keystone_auth_uri   => $ks_public_endpoint,
    notify              => Service['supervisor-cinder-api']
  }
  service { "supervisor-cinder-api":
    ensure   => running,
    start    => "supervisorctl -c /etc/supervisor/supervisor.conf start cinder-api",
    stop     => "supervisorctl -c /etc/supervisor/supervisor.conf stop cinder-api",
    restart  => "supervisorctl -c /etc/supervisor/supervisor.conf restart cinder-api",
    pattern  => "cinder-api"
  }
  class { 'cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
    notify           => Service['supervisor-cinder-scheduler']
  }
  service { "supervisor-cinder-scheduler":
    ensure   => running,
    start    => "supervisorctl -c /etc/supervisor/supervisor.conf start cinder-scheduler",
    stop     => "supervisorctl -c /etc/supervisor/supervisor.conf stop cinder-scheduler",
    restart  => "supervisorctl -c /etc/supervisor/supervisor.conf restart cinder-scheduler",
    pattern  => "cinder=scheduler"
  }
}
