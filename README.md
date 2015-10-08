# dockstack
OpenContrail/OpenStack docker

Dockstack

Dockstack is a proof-of-concept on running OpenStack and OpenContrail as application containers using Docker as the container management layer.
The motiviation is to build an easy-to-install and scalable OpenStack/OpenContrail environment.
Different software components are grouped together as an application container based on scalability requirements:

Application containers:

1. dnsmasq:
 - manages DNS and DHCP for all following containers

2. puppet:
 - provisions configuration into all following containers

3. haproxy/keepalived:
 - provides application loadbalancing and VRRP to all following containers

4. galera:
 - MariaDB Galera database used by the OpenStack container

5. rabbitmq:
 - RabbitMQ message queuing

6. keystone:
 - Identity management

7. nova:
 - Nova controller

8. glance:
 - Image service

9. cinder:
 - Volume service

10. neutron:
 - Network controller

11. dashboard:
 - OpenStack Horizon dashboard

12. cassandra:
 - nosql database used by OpenContrail, includes zookeeper and kafka

13. config:
 - OpenContrail config, ifmap and discovery

14. analytics:
 - OpenContrail analytics

15. control:
 - OpenContrail controller

16. webui:
 - OpenContrail webui
