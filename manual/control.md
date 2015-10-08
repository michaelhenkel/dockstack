The instruction describes the manual setup of an OpenContrail Control Node using
the official PPA. Used variables:
* [README](https://github.com/michaelhenkel/dockstack/blob/master/manual/README.md)

<ol>
<li>software installation</li>
</ol>

```
apt-get -y --force-yes install wget curl software-properties-common
add-apt-repository ppa:opencontrail/ppa
add-apt-repository ppa:opencontrail/r2.20
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
dpkg -i puppetlabs-release-trusty.deb
apt-get update
apt-get install -y --force-yes curl tcpdump iptables openssh-server rsync ntp software-properties-common wget libssl0.9.8 \
					contrail-nodemgr contrail-utils puppet supervisor python-contrail contrail-lib \
                                        contrail-control contrail-dns python-netaddr
```

<ol start=2>
<li>configuration</li>
</ol>

<li>modify /etc/contrail/vnc_api_lib.ini</li>
```
cat << EOF > /etc/contrail/vnc_api_lib.ini
[global]
;WEB_SERVER = 127.0.0.1
;WEB_PORT = 9696  ; connection through quantum plugin

WEB_SERVER = 127.0.0.1
WEB_PORT = 8082 ; connection to api-server directly
BASE_URL = /
;BASE_URL = /tenants/infra ; common-prefix for all URLs

; Authentication settings (optional)
[auth]
AUTHN_TYPE = keystone
AUTHN_PROTOCOL = http
AUTHN_SERVER=$OPENSTACK_IP
AUTHN_PORT = 35357
AUTHN_URL = /v2.0/tokens
EOF
```

<li>create /etc/contrail/contrail-control-nodemgr.conf</li>
```
cat << EOF > /etc/contrail/contrail-control-nodemgr.conf
[DISCOVERY]
server=$CONFIG_IP
port=5998
EOF
```

<li>create /etc/contrail/supervisord_control_files/contrail-nodemgr-control.ini</li>
```
cat << EOF > /etc/contrail/supervisord_control_files/contrail-nodemgr-control.ini
; The below sample eventlistener section shows all possible
; eventlistener subsection values, create one or more 'real'
; eventlistener: sections to be able to handle event notifications
; sent by supervisor.

[eventlistener:contrail-control-nodemgr]
command=/bin/bash -c "exec python /usr/bin/contrail-nodemgr --nodetype=contrail-control"
events=PROCESS_COMMUNICATION,PROCESS_STATE,TICK_60
buffer_size=10000                ; event buffer queue size (default 10)
stdout_logfile=/var/log/contrail/contrail-control-nodemgr-stdout.log ; stdout log path, NONE for none; default AUTO
stderr_logfile=/var/log/contrail/contrail-control-nodemgr-stderr.log ; stderr log path, NONE for none; default AUTO
EOF
```

<li>modify /etc/contrail/dns/contrail-named.conf</li>
```
sed -i "/match-recursive-only no;/a \ \ \ \ forwarders {$DNS_SERVER; };" /etc/contrail/dns/contrail-named.conf
```

<li>modify /etc/contrail/contrail-dns.conf</li>
```
cat << EOF > /etc/contrail/contrail-dns.conf
#
# Copyright (c) 2014 Juniper Networks, Inc. All rights reserved.
#
# DNS configuration options
#

[DEFAULT]
# collectors= # Provided by discovery server
# dns_config_file=dns_config.xml
#  hostip=ctrl1 # Resolved IP of `hostname`
 hostip=$CONTROL_IP # Resolved IP of `hostname`
# dns_server_port=53
# log_category=
# log_disable=0
  log_file=/var/log/contrail/dns.log
# log_files_count=10
# log_file_size=1048576 # 1MB
  log_level=SYS_NOTICE
  log_local=1
# test_mode=0

[DISCOVERY]
# port=5998
  server=$CONFIG_IP # discovery-server IP address

[IFMAP]
    certs_store=
    password=$CONTROL_HOST.dns
  #server_url=https://vip:8443 # Provided by discovery server, e.g. https://127.0.0.1:8443
  user=$CONTROL_HOST.dns
EOF
```

<li>modify /etc/contrail/contrail-control.conf</li>
```
cat << EOF > /etc/contrail/contrail-control.conf
#
# Copyright (c) 2014 Juniper Networks, Inc. All rights reserved.
#
# Control-node configuration options
#

[DEFAULT]
# bgp_config_file=bgp_config.xml
# bgp_port=179
# collectors= # Provided by discovery server
  hostip=$CONTROL_IP # Resolved IP of `hostname`
#  hostip=ctrl1 # Resolved IP of `hostname`
# http_server_port=8083
# log_category=
# log_disable=0
  log_file=/var/log/contrail/contrail-control.log
# log_files_count=10
# log_file_size=10485760 # 10MB
  log_level=SYS_NOTICE
  log_local=1
# test_mode=0
# xmpp_server_port=5269

[DISCOVERY]
# port=5998
  server=$CONFIG_IP # discovery-server IP address

[IFMAP]
  certs_store=
  password=$CONTROL_HOST
  #server_url=https://vip:8443 # Provided by discovery server, e.g. https://127.0.0.1:8443
  user=$CONTROL_HOST
EOF
```

<li>modify /etc/contrail/contrail-discovery.conf</li>
```
sed -i "s/zk_server_ip=127.0.0.1/zk_server_ip=$CASSANDRA_IP/g" /etc/contrail/contrail-discovery.conf
sed -i "s/cassandra_server_list = 127.0.0.1:9160/cassandra_server_list = $CASSANDRA_IP:9160/g" /etc/contrail/contrail-discovery.conf
``` 

<li>provision control node</li>
```
contrail-provision-control --api_server_ip $CONFIG_IP --api_server_port 8082 --host_name $CONTROL_HOST \
--host_ip $CONTROL_IP --router_asn 64512 --oper add --admin_user $ADMIN_USER --admin_password $ADMIN_PASSWORD --admin_tenant $ADMIN_TENANT
```

<li>add host entry</li>
```
echo "$CONTROL_IP $CONTROL_HOST" >> /etc/hosts
```

<li>restart supervisor-control</li>
```
stop supervisor-control
start supervisor-control
```

<li>check status</li>
```
contrail-status
```

<li>ntp workaround (only for docker)</li>
```
cat << EOF > /etc/ntp.conf
restrict 127.0.0.1
restrict ::1
server 127.127.1.0 iburst
driftfile /var/lib/ntp/drift
fudge 127.127.1.0 stratum 5
EOF
service ntp restart
```
