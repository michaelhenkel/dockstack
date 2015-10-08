class mymod::ka (
) inherits mymod::params {
  $ha_index = inline_template('<%= @registered_haproxy.index(@hostname) %>')
  $priority = 100 + $ha_index
  class { 'keepalived':
    service_manage          => false,
  }
  class { 'keepalived::global_defs':
    ensure                  => present,
    router_id               => $::hostname,
  }
  include ::keepalived
  $hostname = $::hostname
  notify { "reg ha: $registered_haproxy":; }
  #$ha_index = inline_template('<%= @registered_haproxy.index(@hostname) %>')
  notify { "index: $ha_index":; }
  if($registered_haproxy[0] == $hostname) {  
      $state = 'MASTER'
  }
  #$priority = 100 + $ha_index
  keepalived::vrrp::script { 'check_haproxy_vip':
    script => '/usr/bin/killall -0 haproxy',
    interval => '1',
    weight => '1',
    fall => '2',
    rise => '2',
  }
  $vip_complete = join([$vip,$vip_mask],'/')
  keepalived::vrrp::instance { 'VI_50':
    interface         => 'eth0',
    state             => $state,
    virtual_router_id => 50,
    priority          => $priority,
    auth_type         => 'PASS',
    auth_pass         => 'secret',
    virtual_ipaddress => [ $vip_complete ],
    track_interface   => ['eth0'], # optional, monitor these interfaces.
    track_script      => ['check_haproxy_vip']
  }
  service { "keepalived":
    ensure   => running,
    start    => "supervisorctl -c /etc/supervisor/supervisor.conf start keepalived",
    stop     => "supervisorctl -c /etc/supervisor/supervisor.conf stop keepalived",
    restart  => "supervisorctl -c /etc/supervisor/supervisor.conf restart keepalived",
    pattern  => "keepalived"
  }
}
