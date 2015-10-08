class mymod::rabbit (
) inherits mymod::params {
  class { '::rabbitmq':
    repos_ensure      => false,
    service_manage    => false,
    port              => '5672',
    delete_guest_user => false,
  }
  service { "rabbitmq-server":
    ensure   => running,
    start    => "supervisorctl -c /etc/supervisor/supervisor.conf start rabbitmq",
    stop     => "supervisorctl -c /etc/supervisor/supervisor.conf stop rabbitmq",
    restart  => "supervisorctl -c /etc/supervisor/supervisor.conf restart rabbitmq",
    pattern  => "rabbitmq-server"
  }
}
