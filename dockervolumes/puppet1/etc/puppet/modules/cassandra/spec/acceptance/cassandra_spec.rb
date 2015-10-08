require 'spec_helper_acceptance'

describe 'cassandra all-in-one' do

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'cassandra': }
      EOS

      # Run it twice for test the idempotency
      apply_manifest(pp)
      apply_manifest(pp)
    end
  end
end
