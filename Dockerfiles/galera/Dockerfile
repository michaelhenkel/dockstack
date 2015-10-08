FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive


EXPOSE 22 3306 4567 4568 4444 9200

RUN apt-get update
RUN apt-get install -y supervisor curl tcpdump iptables openssh-server rsync software-properties-common wget rsync lsof xinetd
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 D669017EBC19DDBA
RUN add-apt-repository 'deb http://releases.galeracluster.com/ubuntu trusty main'
RUN add-apt-repository 'deb http://mirror2.hs-esslingen.de/mariadb/repo/5.5/ubuntu trusty main'
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN dpkg -i puppetlabs-release-trusty.deb
RUN apt-get update
RUN apt-get -y --force-yes install mariadb-galera-server galera-3 mariadb-client puppet
RUN mkdir -p /var/run/sshd /var/log/supervisor
RUN echo 'root:ladakh1' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/START=no/START=yes/' /etc/default/puppet
COPY mysqlchk /etc/xinetd.d/mysqlchk
RUN echo "mysqlchk   9200/tcp" | tee -a /etc/services
ENV container docker
#CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisor.conf"]
CMD ["/sbin/init"]
