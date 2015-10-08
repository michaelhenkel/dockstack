The neutron server must be configured to use the right OpenContrail plugin. It is assumed that the neutron server already exists as part of the OpenStack installation. Used variables:
* [README](https://github.com/michaelhenkel/dockstack/blob/master/manual/README.md)

<ol>
<li>software installation</li>
</ol>

```
add-apt-repository ppa:opencontrail/ppa
add-apt-repository ppa:opencontrail/r2.20
apt-get update
apt-get install -y --force-yes neutron-plugin-contrail
```

<ol start=2>
<li>neutron.conf configuration</li>
</ol>

```
# set the core plugin
sed 's/.*core_plugin.*/core_plugin=neutron_plugin_contrail.plugins.opencontrail.contrail_plugin.NeutronPluginContrailCoreV2/' /etc/neutron.conf
# api extenstion path
sed 's/core_plugin/a api_extensions_path = extensions:/usr/lib/python2.7/dist-packages/neutron_plugin_contrail/extensions/' /etc/neutron.conf
# service plugin
sed 's/core_plugin/a service_plugins = neutron_plugin_contrail.plugins.opencontrail.loadbalancer.plugin.LoadBalancerPlugin/' /etc/neutron.conf
#quota
echo '[quotas]\nquota_driver = neutron_plugin_contrail.plugins.opencontrail.quota.driver.QuotaDriver\n' >> /etc/neutron.conf
echo '[QUOTAS]\nquota_network = -1/nquota_subnet = -1\nquota_port = -1\n' >> /etc/neutron.conf
# service providers section
echo '[service_providers]\nservice_provider = LOADBALANCER:Opencontrail:neutron_plugin_contrail.plugins.opencontrail.loadbalancer.driver.Openc
ontrailLoadbalancerDriver:default\n' >> /etc/neutron.conf
```

<ol start=3>
<li>OpenContrail plugin configuration</li>
</ol>

```
cat << EOF > /etc/neutron/plugins/opencontrail/ContrailPlugin.ini
[APISERVER]
api_server_ip = $CONFIG_IP
api_server_port = 8082
multi_tenancy = True
contrail_extensions = ipam:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_ipam.NeutronPluginContrailIpam,policy:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_policy.NeutronPluginContrailPolicy,route-table:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_vpc.NeutronPluginContrailVpc,contrail:None

[COLLECTOR]
analytics_api_ip = $ANALYTICS_IP
analytics_api_port = 9081

[KEYSTONE]
auth_url = http://$OPENSTACK_IP:35357/v2.0
admin_token = $ADMIN_TOKEN
admin_user= $ADMIN_USER
admin_password= $ADMIN_PASSWORD
admin_tenant_name= $ADMIN_TENANT
```

<ol start=4>
<li>restart neutron server</li>
</ol>
```
service neutron-server restart
```
