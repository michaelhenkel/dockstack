FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

#CMD ["/usr/bin/supervisord"]

RUN apt-get -y --force-yes install wget
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN dpkg -i puppetlabs-release-trusty.deb
RUN apt-get update
RUN apt-get install -y puppet curl tcpdump iptables openssh-server wget dnsmasq
RUN sed -i 's/START=no/START=yes/' /etc/default/puppet
RUN echo 'root:ladakh1' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/#conf-dir=\/etc\/dnsmasq.d/conf-dir=\/etc\/dnsmasq.d/g' /etc/dnsmasq.conf
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV container docker
CMD ["/usr/sbin/dnsmasq","-d"]
