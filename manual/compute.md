The nova compute node must be configured to use the vrouter module. It is assumed that the nova compute node is already installed as part of the OpenStack installation. Used variables:
* [README](https://github.com/michaelhenkel/dockstack/blob/master/manual/README.md)

<ol>
<li>software installation</li>
</ol>

```
add-apt-repository ppa:opencontrail/ppa
add-apt-repository ppa:opencontrail/r2.20
apt-get update
apt-get install -y --force-yes contrail-nova-driver contrail-utils
```

<ol start=2>
<li>create if-vhost0</li>
</ol>

```
cat << EOF > /usr/share/contrail-utils/if-vhost0
#!/bin/bash

source /usr/share/contrail-utils/vrouter-functions.sh

if [ ! -L /sys/class/net/vhost0 ]; then
    insert_vrouter &>> $LOG
fi
EOF
chmod +x /usr/share/contrail-utils/if-vhost0
```

<ol start=3>
<li>get vrouter-functions.sh</li>
</ol>
```
cd /usr/share/contrail-utils
wget https://raw.githubusercontent.com/Juniper/contrail-packaging/master/common/control_files/vrouter-functions.sh
chmod +x vrouter-functions.sh
```

<ol start=4>
<li>vrouter configuration</li>
</ol>

```
cat << EOF > /etc/network/interface
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet manual
    pre-up ifconfig eth0 up
    post-down ifconfig eth0 down

auto vhost0
iface vhost0 inet static
    pre-up /usr/share/contrail-utils/if-vhost0
    netmask $SUBNET
    network_name application
    address $COMPUTE_IP
    gateway $GATEWAY
    dns-nameservers $DNS_SERVER
EOF
```

<ol start=5>
<li>nova configuration</li>
</ol>
```
sed -i 's/.*libvirt_vif_driver.*/libvirt_vif_driver = nova_contrail_vif.contrailvif.VRouterVIFDriver/g' /etc/nova/nova.conf
cat << EOF > /etc/nova/nova-compute.conf
[DEFAULT]
compute_driver=libvirt.LibvirtDriver
network_api_class = nova_contrail_vif.contrailvif.ContrailNetworkAPI
[libvirt]
virt_type=kvm
EOF
```

<ol start=6>
<li>reboot compute node</li>
</ol>
```
reboot
```
<ol start=7>
<li>provision vrouter</li>
</ol>
```
/usr/share/contrail/provision_vrouter.py --host_name $COMPUTE_HOST --host_ip $COMPUTE_IP --control_names $CONTROL_IP --api_server_ip $CONFIG_IP --api_server_port 8082 --oper add --admin_user $ADMIN_USER --admin_password $ADMIN_PASSWORD --admin_tenant_name $ADMIN_TENANT
```
