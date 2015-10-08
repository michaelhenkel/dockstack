# == Class: cassandra::repository
#
# Define Cassandra Datastak repository
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class cassandra::repository {

  case $::osfamily {
    'Debian': {
      if $::lsbdistrelease == '14.04' {

        include apt
        include apt::update

        apt::source {'datastax':
          location    => 'http://debian.datastax.com/community',
          comment     => 'DataStax Repo for Apache Cassandra',
          release     => 'stable',
          key         => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
          key_source  => 'http://debian.datastax.com/debian/repo_key',
          include_src => false
        }

        # Dummy exec to wrap apt_update
        exec {'update-cassandra-repos':
          command => '/bin/true',
          require => Exec['apt_update']
        }

        Apt::Source<| |> -> Exec<| command == 'update-cassandra-repos' |>

      }
      else {
        fail('Operating System not supported by this module')
      }
    }
    'RedHat': {
      if ($::operatingsystemmajrelease == 7 or
          $::operatingsystemmajrelease == 6) {

        yumrepo { 'datastax':
          baseurl  => 'http://rpm.datastax.com/community',
          descr    => 'DataStax Repo for Apache Cassandra',
          enabled  => 1,
          gpgcheck => 0,
          gpgkey   => 'https://rpm.datastax.com/rpm/repo_key',
          timeout  => 60
        }

        exec {'update-cassandra-repos':
          command => '/usr/bin/yum clean all && /usr/bin/yum makecache',
        }

        Yumrepo<| |> -> Exec<| command == 'update-cassandra-repos' |>
      }
      else {
        fail('Operating System not supported by this module')
      }
    }
    default: {
      fail('Operating System not supported by this module')
    }
  }

}
