FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

#CMD ["/usr/bin/supervisord"]


EXPOSE 22 8103 9160 9042 53431 7000 56221 7199 2181 49613 3888 44145 57886
RUN echo "deb http://www.apache.org/dist/cassandra/debian 21x main" >> /etc/apt/sources.list
RUN echo "deb-src http://www.apache.org/dist/cassandra/debian 21x main" >> /etc/apt/sources.list
RUN gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
RUN gpg --export --armor F758CE318D77295D | sudo apt-key add -
RUN gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
RUN gpg --export --armor 2B5C1B00 | sudo apt-key add -
RUN gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
RUN gpg --export --armor 0353B12C | sudo apt-key add -
RUN apt-get update
RUN apt-get -y --force-yes install wget curl software-properties-common
RUN add-apt-repository ppa:opencontrail/ppa
RUN add-apt-repository ppa:opencontrail/r2.20
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN dpkg -i puppetlabs-release-trusty.deb
RUN apt-get update
RUN apt-get install -y --force-yes curl tcpdump iptables openssh-server rsync software-properties-common wget libssl0.9.8 \
					contrail-nodemgr contrail-utils zookeeper supervisor ntp \
                                        python-pycassa cassandra cassandra-tools python-cassandra-driver kafka puppet 
RUN apt-get -q -y update
RUN mkdir -p /var/run/sshd /var/log/supervisor
RUN sed -i 's/START=no/START=yes/' /etc/default/puppet
RUN echo 'root:ladakh1' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN rm /usr/sbin/policy-rc.d; \
        rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV container docker
RUN sed -i "/storage = package_installed('contrail-storage')/a \ \ \ \ database = True" /usr/bin/contrail-status
RUN sed -i 's/JVM_OPTS="$JVM_OPTS -Xss180k"/JVM_OPTS="$JVM_OPTS -Xss512k"/g' /etc/cassandra/cassandra-env.sh
RUN mkdir /var/log/contrail
COPY supervisord_database_files /etc/contrail/supervisord_database_files
COPY supervisord_database.conf /etc/contrail/supervisord_database.conf
COPY supervisor-database.conf /etc/init/supervisor-database.conf
COPY zookeeper.conf /etc/init/zookeeper.conf

#CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord_database.conf"]
CMD ["/sbin/init"]
