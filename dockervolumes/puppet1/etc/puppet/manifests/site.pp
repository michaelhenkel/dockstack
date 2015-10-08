#nodes
node 'haproxy' ,'haproxy1.endor.lab' {
  class { '::mymod::ha': }
  class { '::mymod::ka': }
}
node 'galera' ,'galera1.endor.lab' {
  class { '::mymod::gal': }
}
node 'keyston' {
  class { '::mymod::ks': }
}
node 'redis' {
  class { '::mymod::redis': }
}
node 'rabbitmq' ,'rabbitmq1.endor.lab' {
  class { '::mymod::rabbit': }
}
node 'keystone' ,'keystone1.endor.lab' {
  class { '::mymod::ks': }
}
node 'openstack' {
  class { '::mymod::os': }
}
node 'glance' ,'glance1.endor.lab' {
  class { '::mymod::gl': }
}
node 'cinder' ,'cinder1.endor.lab' {
  class { '::mymod::ci': }
}
node 'nova' ,'nova1.endor.lab' {
  class { '::mymod::no': }
}
node 'neutron' ,'neutron1.endor.lab' {
  class { '::mymod::ne': }
}
node 'dashboard' ,'dashboard1.endor.lab' {
  class { '::mymod::da': }
}
node 'cassandra' ,'cassandra1.endor.lab' {
  class { '::mymod::cas': }
}
node 'config' ,'config1.endor.lab' {
  class { '::mymod::conf': }
}
node 'analytics' ,'analytics1.endor.lab' {
  class { '::mymod::ana': }
}
node 'control' ,'control1.endor.lab' {
  class { '::mymod::ctrl': }
}
node 'webui' ,'webui1.endor.lab' {
  class { '::mymod::web': }
}
node 'compute' ,'compute1.endor.lab' ,'compute2.endor.lab' {
  class { '::dockstack::novacompute': }
}
