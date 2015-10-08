class dockstack::gl (
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

  class { 'glance::api':
    verbose             => true,
    keystone_password   => $keystone_admin_password,
    database_connection => $glance_sql,
    auth_uri            => $ks_private_endpoint,
    auth_url            => $auth_url,
    auth_host           => $vip_name,
    pipeline            => 'keystone',
    notify                        => Service['supervisor-glance-api']
  }
  class { 'glance::notify::rabbitmq':
    rabbit_password               => 'guest',
    rabbit_userid                 => 'guest',
    rabbit_host                   => $rabbit_host,
    rabbit_use_ssl                => false,
  }
  service { "supervisor-glance-api":
    ensure   => running,
    start    => "supervisorctl -c /etc/supervisor/supervisor.conf start glance-api",
    stop     => "supervisorctl -c /etc/supervisor/supervisor.conf stop glance-api",
    restart  => "supervisorctl -c /etc/supervisor/supervisor.conf restart glance-api",
    pattern  => "glance-api"
  }
  class { 'glance::backend::file': }
  class { 'glance::config':
    api_config          => {
      'keystone_authtoken/identity_uri' => { value => $ks_admin_endpoint },
    },
    registry_config     => {
      'DEFAULT/rabbit_host' => { value => $vip_name },
      'keystone_authtoken/identity_uri' => { value => $ks_admin_endpoint },
    },
  }

  class { 'glance::registry':
    verbose             => true,
    keystone_password   => $keystone_admin_password,
    database_connection => $glance_sql,
    auth_uri            => $ks_private_endpoint,
    auth_host           => $vip_name,
  }
  service { "supervisor-glance-registry":
    ensure   => running,
    start    => "supervisorctl -c /etc/supervisor/supervisor.conf start glance-registry",
    stop     => "supervisorctl -c /etc/supervisor/supervisor.conf stop glance-registry",
    restart  => "supervisorctl -c /etc/supervisor/supervisor.conf restart glance-registry",
    pattern  => "glance-registry"
  }
  #file { "/etc/glance/glance-api.conf":
  #  notify     => Service['supervisor-glance-api'],
  #  mode       => 640,
  #  owner      => "glance",
  #  group      => "glance",
  #}
  #file { "/etc/glance/glance-registry.conf":
  #  notify     => Service['supervisor-glance-registry'],
  #  mode       => 640,
  #  owner      => "glance",
  #  group      => "glance",
  #}
}
