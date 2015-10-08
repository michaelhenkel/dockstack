require 'spec_helper'

describe 'cassandra' do

  shared_examples_for 'single cassandra' do
    let :params do
    {
      :seeds        => ['192.168.7.2', '192.168.7.3', '192.168.7.4'],
      :seed_address => '192.168.7.2'
    }
    end

    it 'should call install and run' do
      is_expected.to contain_class('cassandra::install')
      is_expected.to contain_class('cassandra::run').with({
          'seeds'              => params[:seeds],
          'seed_address'       => params[:seed_address],
          'storage_port'       => '7000',
          'ssl_storage_port'   => '7001',
          'client_port'        => '9042',
          'client_port_thrift' => '9160'
      })
    end
  end


  context 'on Debian' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistrelease  => '14.04',
        :lsbdistid       => 'Ubuntu',
        :lsbdistcodename => 'trusty',
        :ipaddress       => '127.0.0.1',
        :hostname        => 'test.puppet'
      }
    end
    it_configures 'single cassandra'
  end


  context 'on RedHat' do
    let :facts do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'CentOS',
        :operatingsystemmajrelease => 7,
        :ipaddress                 => '127.0.0.1',
        :hostname                  => 'test.puppet'
      }
    end
    it_configures 'single cassandra'
  end
end
