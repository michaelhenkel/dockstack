#!/bin/bash
docker exec puppet1 /usr/bin/supervisorctl -c /etc/supervisor/supervisor.conf stop apache2
docker exec puppet1 puppet cert generate puppet1.endor.lab
docker exec puppet1 sed -i "s/.*SSLCertificateFile.*/        SSLCertificateFile      \/var\/lib\/puppet\/ssl\/certs\/puppet1.endor.lab.pem/g" /etc/apache2/sites-enabled/puppetmaster.conf
docker exec puppet1 sed -i "s/.*SSLCertificateKeyFile.*/        SSLCertificateKeyFile      \/var\/lib\/puppet\/ssl\/private_keys\/puppet1.endor.lab.pem/g" /etc/apache2/sites-enabled/puppetmaster.conf
docker exec puppet1 /usr/bin/supervisorctl -c /etc/supervisor/supervisor.conf start apache2
