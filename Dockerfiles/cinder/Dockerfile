FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y --force-yes install wget curl software-properties-common
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN dpkg -i puppetlabs-release-trusty.deb
RUN add-apt-repository -y cloud-archive:juno
RUN apt-get update
RUN apt-get install -y --force-yes puppet tcpdump iptables openssh-server supervisor python-mysqldb \
                                   cinder-volume cinder-api cinder-scheduler python-cinderclient lvm2 python-openstackclient
RUN mkdir -p /var/run/sshd 
RUN sed -i 's/START=no/START=yes/' /etc/default/puppet
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV container docker
RUN touch /etc/init.d/supervisor-cinder-api
RUN touch /etc/init.d/supervisor-cinder-scheduler
RUN touch /etc/init.d/supervisor-cinder-volume
RUN touch /etc/init.d/supervisor-tgt
RUN echo  'echo "initctl (upstart 1.12.1)"' > /sbin/initctl
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisor.conf"]
