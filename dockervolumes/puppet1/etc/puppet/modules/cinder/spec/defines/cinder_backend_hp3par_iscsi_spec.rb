require 'spec_helper'

describe 'cinder::backend::hp3par_iscsi' do
  let (:title) { 'hp3par_iscsi' }

  let :req_params do
    {
      :hp3par_api_url   => 'https://172.0.0.2:8080/api/v1',
      :hp3par_username  => '3paradm',
      :hp3par_password  => 'password',
      :hp3par_iscsi_ips => '172.0.0.3',
      :san_ip           => '172.0.0.2',
      :san_login        => '3paradm',
      :san_password     => 'password',
    }
  end

  let :params do
    req_params
  end

  describe 'hp3par_iscsi volume driver' do
    it 'configure hp3par_iscsi volume driver' do
      should contain_cinder_config('hp3par_iscsi/volume_driver').with_value('cinder.volume.drivers.san.hp.hp_3par_iscsi.HP3PARISCSIDriver')
      should contain_cinder_config('hp3par_iscsi/hp3par_api_url').with_value('https://172.0.0.2:8080/api/v1')
      should contain_cinder_config('hp3par_iscsi/hp3par_username').with_value('3paradm')
      should contain_cinder_config('hp3par_iscsi/hp3par_password').with_value('password')
      should contain_cinder_config('hp3par_iscsi/hp3par_iscsi_ips').with_value('172.0.0.3')
      should contain_cinder_config('hp3par_iscsi/san_ip').with_value('172.0.0.2')
      should contain_cinder_config('hp3par_iscsi/san_login').with_value('3paradm')
      should contain_cinder_config('hp3par_iscsi/san_password').with_value('password')
    end
  end
end
