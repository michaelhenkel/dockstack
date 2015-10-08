FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

#CMD ["/usr/bin/supervisord"]


EXPOSE 22 80 443 3306

RUN apt-get update
RUN apt-get install -y supervisor curl tcpdump iptables openssh-server wget apache2 psmisc ruby-dev ruby ruby-passenger
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN dpkg -i puppetlabs-release-trusty.deb
RUN apt-get update
RUN apt-get install -y puppetmaster-passenger
#RUN sed -i 's/START=no/START=yes/' /etc/default/puppet
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
RUN puppet module install puppetlabs-stdlib
RUN puppet module install puppetlabs-haproxy
RUN puppet module install arioch-keepalived
RUN puppet module install michaeltchapman-galera
RUN puppet module install puppetlabs-rabbitmq
RUN puppet module install puppetlabs-inifile
RUN puppet module install aimonb/aviator
RUN puppet module install stackforge-openstacklib --version 5.1.0  --ignore-dependencies
RUN puppet module install stackforge-keystone --version 5.1.0  --ignore-dependencies
RUN puppet module install stackforge-glance --version 5.1.0
RUN puppet module install dprince/qpid
RUN puppet module install stackforge-cinder --ignore-dependencies
RUN puppet module install stackforge-nova --ignore-dependencies
RUN puppet module install stackforge-neutron --ignore-dependencies
ENV container docker
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisor.conf"]
