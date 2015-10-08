The instruction describes the manual setup of an OpenContrail WebUI Node using
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
                                        contrail-web-core contrail-web-controller nodejs=0.8.15-1contrail1
```

<ol start=2>
<li>configuration</li>
</ol>

<li>modify /etc/contrail/config.global.js</li>
```

sed -i "s/config.networkManager.ip = '127.0.0.1';/config.networkManager.ip = '$OPENSTACK_IP';/g" /etc/contrail/config.global.js
sed -i "s/config.imageManager.ip = '127.0.0.1';/config.imageManager.ip = '$OPENSTACK_IP';/g" /etc/contrail/config.global.js
sed -i "s/config.computeManager.ip = '127.0.0.1';/config.computeManager.ip = '$OPENSTACK_IP';/g" /etc/contrail/config.global.js
sed -i "s/config.identityManager.ip = '127.0.0.1';/config.identityManager.ip = '$OPENSTACK_IP';/g" /etc/contrail/config.global.js
sed -i "s/config.storageManager.ip = '127.0.0.1';/config.storageManager.ip = '$OPENSTACK_IP';/g" /etc/contrail/config.global.js
sed -i "s/config.cnfg.server_ip = '127.0.0.1';/config.cnfg.server_ip = '$CONFIG_IP';/g" /etc/contrail/config.global.js
sed -i "s/config.analytics.server_ip = '127.0.0.1';/config.analytics.server_ip = '$ANALYTICS_IP';/g" /etc/contrail/config.global.js
sed -i "s/config.discoveryService.enable = false;/config.discoveryService.enable = true;/g" /etc/contrail/config.global.js
sed -i "/config.discoveryService = {};/a config.discoveryService.ip = '$CONFIG_IP'" /etc/contrail/config.global.js
sed -i "s/config.cassandra.server_ips = \['127.0.0.1'\];/config.cassandra.server_ips =  \['$CASSANDRA_IP'\]/g" /etc/contrail/config.global.js

<li>start redis-server</li>
```
service redis-server start
```

<li>start contrail webui</li>
```
start contrail-webui-jobserver
start contrail-webui-webserver
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
