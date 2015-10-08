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

The Container application configurations rely on predictable ip addressing. 
Per default docker reassignes new ip addresses in case a Container is stopped and restarted. 
Chaning ip addresses will break most of the applications.
Therefore the containers are started without networking and ovs-docker is used to provide networking to a Container:

```
CONTAINER_ID=`docker run -d --name CONTAINERNAME --net=none IMAGE CMD`
ovs-docker add-port BR eth0 $CONTAINER_ID IPADDRESS/MASK GATEWAY
```

The first command creates a container and the second adds the eth0 interface  
with an ip address and a gateway to the container.  
The same ovs-docker command can be used after restarting 
a stopped container:

```
docker start CONTAINERNAME
CONTAINER_ID=`docker inspect --format='{{.Id}}' CONTAINERNAME`
ovs-docker add-port BR eth0 $CONTAINER_ID IPADDRESS/MASK GATEWAY
```

In order to build the containers the git repo must be cloned:

```
git clone https://github.com/michaelhenkel/dockstack
```

The dockstack/Dockerfiles directory contains one directory for each container.
The Dockerfile used for building the containers is located in that directory:

```
ll Dockerfiles/config
total 16
drwxr-xr-x  2 root root 4096 Sep 10 17:18 ./
drwxr-xr-x 18 root root 4096 Sep 13 14:52 ../
-rw-r--r--  1 root root 1324 Sep 10 17:18 Dockerfile
```

A container is built using the docker build command from inside the container directory:

```
root@docker-dev:/etc/dockstack/Dockerfiles/config# docker build -t config .
Sending build context to Docker daemon  5.12 kB
Step 0 : FROM ubuntu:14.04
 ---> 91e54dfb1179
Step 1 : ENV DEBIAN_FRONTEND noninteractive
 ---> Using cache
 ---> d31fb91faf58
Step 2 : RUN apt-get update
 ---> Using cache
 ---> 89567028a0bf
Step 3 : RUN apt-get -y --force-yes install wget curl software-properties-common
 ---> Using cache
 ---> 95f738e3f4f9
Step 4 : RUN add-apt-repository ppa:opencontrail/ppa
.
.
.
Removing intermediate container 9bfe805c19df
Step 20 : ENV container docker
 ---> Running in cd4b78d3e928
 ---> 57bedb8ae122
Removing intermediate container cd4b78d3e928
Step 21 : CMD /sbin/init
 ---> Running in 53ea06889a5e
 ---> 03a59cd51fbd
Removing intermediate container 53ea06889a5e
Successfully built 03a59cd51fbd
```

This builds the config container:

```
root@docker-dev:/etc/dockstack# docker images config
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
config              latest              11554d328cb6        12 days ago         675.2 MB
```

All containers use supervisord as the init tool. Some of them directly, others through upstart.
The supervisor configuration files are located on the host and are mounted to the container
as a volume when it is run. Therefore it is required to have a volume directory per container
on the host. The dockervolumes directory contains examples for each container:

```
ll dockervolumes/
analytics1/ cinder1/    config4/    dashboard1/ dns1/       glance1/    keystone1/  nova1/      rabbitmq1/
cassandra1/ config1/    control1/   default/    galera1/    haproxy1/   neutron1/   puppet1/

ll dockervolumes/config1/etc/supervisor/conf.d/
contrail-api.conf             contrail-device-manager.conf  contrail-nodemgr-config.conf  contrail-svc-monitor.conf     ntpd.conf
contrail-config.rules         contrail-discovery.conf       contrail-schema.conf          ifmap.conf
```

The directories below dockervolumes are named after the container name. In order to run a container 
with a mounted volume the following command must be used:

```
docker run -d --name config1 --net=none -v /etc/dockerstack/dockervolumes/config1/etc/supervisor/:/etc/supervisor config1
```

docker inspect shows the mounted volumes:

```
docker inspect --format='{{.Mounts}}' config1
[{ /etc/dockstack/dockervolumes/config1/etc/supervisor /etc/supervisor   true}]
```

Once all containers are started the applications must be configured. Manual configuration of the 
Contrail components is explained in manual/README.md. Configuration of the OpenStack components
is explained here http://docs.openstack.org/juno/install-guide/install/apt/content/ch_preface.html.
In order to access the configuration files of a container a bash session must be started:

```
root@docker-dev:/etc/dockstack# docker exec -it config1 /bin/bash
root@config1:/# ll /etc/contrail/
total 40
drwxr-x--- 1 contrail contrail  460 Oct  6 09:48 ./
drwxr-xr-x 1 root     root     2474 Oct  2 06:50 ../
-rw-r--r-- 1 contrail contrail  875 Oct  2 06:50 contrail-api.conf
-rw-r--r-- 1 root     root       34 Oct  2 06:50 contrail-config-nodemgr.conf
-rw-r--r-- 1 contrail contrail  265 Oct  2 06:50 contrail-device-manager.conf
-rw-r--r-- 1 contrail contrail 1120 Oct  2 06:50 contrail-discovery.conf
-rw-r--r-- 1 root     root      193 Oct  2 06:51 contrail-keystone-auth.conf
-rw-r--r-- 1 contrail contrail  361 Oct  2 06:50 contrail-schema.conf
-rw-r--r-- 1 contrail contrail 1353 Oct  2 06:50 contrail-svc-monitor.conf
-rw-r--r-- 1 contrail contrail 6092 Aug 31 06:47 supervisord_config.conf
drwxr-xr-x 1 contrail contrail  312 Oct  6 09:06 supervisord_config_files/
-rw-r--r-- 1 contrail contrail  502 Oct  2 06:50 vnc_api_lib.ini
```

All containers are installed with puppet and the repository contains a puppet master container
with all the modules required for configuring the OpenStack and the Contrail components.
The modules directory and other files are mounted into the puppet container:

```
```

The common.yaml file contains a definition of the environment. The registered_services array  
must be updated with the running containers:

```
common:
  dnsServer: 10.0.0.1
  domain: endor.lab
  galera_password: password
  haproxy_password: password
  haproxy_user: birdman
  keystone_admin_password: password
  keystone_admin_tenant: admin
  keystone_admin_token: password
  keystone_admin_user: admin
  puppetServer: puppet1
  vip: 10.0.0.254
  vip_mask: '16'
  vip_name: vip
registered_services:
  dns:
  puppet:
  - puppet1
  haproxy:
  - haproxy1
  galera:
  - galera1
  redis:
  rabbitmq:
  - rabbitmq1
  keystone:
  - keystone1
  glance:
  - glance1
  cinder:
  - cinder1
  neutron:
  - neutron1
  nova:
  - nova1
  dashboard:
  - dashboard1
  cassandra:
  - cassandra1
  config:
  - config1
  control:
  - control1
  analytics:
  - analytics1
  webui:
  - webui1
```

The site.pp file defines the puppet modules to be used per container. The contailer
hostname and domain name must be adjusted:

```
root@docker-dev:/etc/dockstack# cat dockervolumes/puppet1/etc/puppet/manifests/site.pp
#nodes
node 'haproxy' ,'haproxy1.endor.lab' {
  class { '::dockstack::ha': }
  class { '::dockstack::ka': }
}
node 'galera' ,'galera1.endor.lab' {
  class { '::dockstack::gal': }
}
node 'keyston' {
  class { '::dockstack::ks': }
}
node 'redis' {
  class { '::dockstack::redis': }
}
node 'rabbitmq' ,'rabbitmq1.endor.lab' {
  class { '::dockstack::rabbit': }
}
node 'keystone' ,'keystone1.endor.lab' {
  class { '::dockstack::ks': }
}
node 'openstack' {
  class { '::dockstack::os': }
}
node 'glance' ,'glance1.endor.lab' {
  class { '::dockstack::gl': }
}
node 'cinder' ,'cinder1.endor.lab' {
  class { '::dockstack::ci': }
}
node 'nova' ,'nova1.endor.lab' {
  class { '::dockstack::no': }
}
node 'neutron' ,'neutron1.endor.lab' {
  class { '::dockstack::ne': }
}
node 'dashboard' ,'dashboard1.endor.lab' {
  class { '::dockstack::da': }
}
node 'cassandra' ,'cassandra1.endor.lab' {
  class { '::dockstack::cas': }
}
node 'config' ,'config1.endor.lab' {
  class { '::dockstack::conf': }
}
node 'analytics' ,'analytics1.endor.lab' {
  class { '::dockstack::ana': }
}
node 'control' ,'control1.endor.lab' {
  class { '::dockstack::ctrl': }
}
node 'webui' ,'webui1.endor.lab' {
  class { '::dockstack::web': }
}
node 'compute' ,'compute1.endor.lab' ,'compute2.endor.lab' {
  class { '::dockstack::novacompute': }
}
```

The repository contains a client/server application which helps to
automatically  
- run/destroy/start/stop a container  
- provision configuration into a container  

The application uses an yaml environment file to describe the infrastructure:

```
root@docker-dev:/etc/dockstack# cat environment.yaml
common:
  vip_name: vip				#hostname for the virtual IP
  vip: 10.0.0.254			#virtual IP
  vip_mask: 16   			#netmask for vip in CIDR
  domain: endor.lab
  keystone_admin_password: password
  keystone_admin_user: admin
  keystone_admin_tenant: admin
  galera_password: password
  haproxy_user: birdman
  haproxy_password: password
containerhosts:				#section for container hosts
  host1: &host1
    ip: 192.168.1.48  			#ip address of container host
    port: 3288				#port the server application is listening on
  host2:
    ip: 192.168.1.49
    port: 3288
containerdefault: &containerdefault	#container default values
  mask: 16
  gateway: 10.0.0.100
  dns: 10.0.0.1
  domain: endor.lab
  bridge: br0
  host: *host1
  volumes:
  precreation:
  postcreation:
  postdestroy:
containers:				#container section
  dns1:					#container name
    <<: *containerdefault
    ip: 10.0.0.1
    image: dns
    volumes:				#list of volumes to mount
    - /dockervolumes/dns1/dnsmasq.d:/etc/dnsmasq.d
    state: true
  puppet1:
    <<: *containerdefault
    ip: 10.0.0.2
    image: puppet
    volumes:
    - /dockervolumes/default/supervisor.conf:/etc/supervisor/supervisor.conf
    - /dockervolumes/puppet1/etc/puppet/hieradata/common.yaml:/etc/puppet/hieradata/common.yaml
    - /dockervolumes/puppet1/etc/supervisor/conf.d:/etc/supervisor/conf.d
    - /dockervolumes/puppet1/etc/puppet/hiera.yaml:/etc/puppet/hiera.yaml
    - /dockervolumes/puppet1/etc/puppet/modules:/etc/puppet/modules
    - /dockervolumes/puppet1/etc/puppet/manifests/site.pp:/etc/puppet/manifests/site.pp
    - /dockervolumes/puppet1/etc/puppet/puppet.conf:/etc/puppet/puppet.conf
    - /dockervolumes/puppet1/var/www:/var/www
    state: true
    postcreation:				#list of scripts to run after container run
    - /dockervolumes/puppet1/createcert.sh
    - /dockervolumes/default/registerService.py add --container puppet1 --service
      puppet
    - /dockervolumes/default/registerService.py adddns --container puppet1 --ipaddress
      10.0.0.2 --domain endor.lab
    postdestroy:				#list of scripts to run after container destroy
    - /dockervolumes/default/registerService.py del --container puppet1 --service
      puppet
    - /dockervolumes/default/registerService.py deldns --container puppet1 --ipaddress
      10.0.0.2 --domain endor.lab
  haproxy1:
    <<: *containerdefault
    ip: 10.0.0.3
    image: haproxy
    volumes:
    - /dockervolumes/default/supervisor.conf:/etc/supervisor/supervisor.conf
    - /dockervolumes/default/puppet.conf:/etc/puppet/puppet.conf
    - /dockervolumes/haproxy1/etc/supervisor/conf.d:/etc/supervisor/conf.d
    precreation:      				#list of scripts to run after container run
    - /dockervolumes/default/registerService.py delcert --container haproxy1 --domain
      endor.lab --master puppet1
    postcreation:
    - /dockervolumes/default/registerService.py add --container haproxy1 --service
      haproxy
    - /dockervolumes/default/registerService.py adddns --container haproxy1 --ipaddress
      10.0.0.3 --domain endor.lab
    - /dockervolumes/default/registerService.py addnode --container haproxy1 --service
      haproxy --domain endor.lab
    - /dockervolumes/default/registerService.py getconfig --container haproxy1
    postdestroy:
    - /dockervolumes/default/registerService.py del --container haproxy1 --service
      haproxy
    - /dockervolumes/default/registerService.py deldns --container haproxy1 --ipaddress
      10.0.0.3 --domain endor.lab
    - /dockervolumes/default/registerService.py delnode --container haproxy1 --service
      haproxy --domain endor.lab
    state: true
```

The server is started with

```
./dockstack-server listen
```

The client can then deploy a container:

```
./dockstack -c config1 run
```

