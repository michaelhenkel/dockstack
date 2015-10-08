The nova controller must be configured to use the right OpenContrail plugin. It is assumed that the nova controller already exists as part of the OpenStack installation. Used variables:
* [README](https://github.com/michaelhenkel/dockstack/blob/master/manual/README.md)

<ol>
<li>software installation</li>
</ol>
```
add-apt-repository ppa:opencontrail/ppa
add-apt-repository ppa:opencontrail/r2.20
apt-get update
apt-get install -y --force-yes contrail-nova-driver
```

<ol start=2>
<li>nova.conf configuration</li>
</ol>
```
sed 's/\[DEFAULT\]/a network_api_class = nova_contrail_vif.contrailvif.ContrailNetworkAPI/' /etc/nova.conf
```

<ol start=3>
<li>restart nova</li>
</ol>
```
for i in nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler
do
  restart $i
done
```
