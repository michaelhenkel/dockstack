class mymod::ks (
) inherits mymod::params {
  $ks_sql = join(["mysql://keystone:",$keystone_admin_password,"@",$vip_name,".",$domain,"/keystone"],'')
  $ks_public_endpoint = join(["http://",$vip_name,".",$domain,":5000/"],'')
  $ks_admin_endpoint = join(["http://",$vip_name,".",$domain,":35357/"],'')
  $auth_uri = join(["http://",$vip_name,".",$domain,":5000/v2.0"],'')
  notify { "ksql $ks_sql":; }

  service { "supervisor":
    ensure   => running,
    start    => "supervisorctl -c /etc/supervisor/supervisor.conf start keystone",
    stop     => "supervisorctl -c /etc/supervisor/supervisor.conf stop keystone",
    restart  => "supervisorctl -c /etc/supervisor/supervisor.conf restart keystone",
    pattern  => "keystone"
  }

  class { 'keystone':
    service_name => 'supervisor',
    catalog_type   => 'sql',
    admin_token    => $keystone_admin_token,
    database_connection => $ks_sql,
    rabbit_host => $vip_name,
  }->
  
 class { 'keystone::roles::admin':
    email        => 'admin@example.com',
    password     => $keystone_admin_password,
    admin_tenant_desc => 'admin_tenant',
    admin_tenant => 'admin',
 }->

  class { 'keystone::endpoint':
    public_address   => $vip_name,
    admin_address    => $vip_name,
    internal_address => $vip_name,
    region           => 'RegionOne'
  }
  if (size($registered_glance) > 0 ){ 
    notify{"reg glance $registered_glance":;}
    class { 'glance::keystone::auth':
      auth_name        => 'glance',
      password         => $keystone_admin_password,
      public_address   => $vip_name,
      admin_address    => $vip_name,
      internal_address => $vip_name,
    }
  }

  if (size($registered_cinder) > 0 ){
    notify{"reg cinder $registered_cinder":;}
    class { 'cinder::keystone::auth':
      auth_name        => 'cinder',
      password         => $keystone_admin_password,
      public_address   => $vip_name,
      admin_address    => $vip_name,
      internal_address => $vip_name,
    }
  }
  if (size($registered_nova) > 0 ){
    notify{"reg cinder $registered_nova":;}
    class { 'nova::keystone::auth':
      auth_name        => 'nova',
      password         => $keystone_admin_password,
      public_address   => $vip_name,
      admin_address    => $vip_name,
      internal_address => $vip_name,
    }
  }

  if (size($registered_neutron) > 0 ){
    class { 'neutron::keystone::auth':
      password            => $keystone_admin_password,
      public_address      => $vip_name,
      admin_address       => $vip_name,
      internal_address    => $vip_name,
    }
  }


}
