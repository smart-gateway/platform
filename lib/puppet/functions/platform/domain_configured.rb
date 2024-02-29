# frozen_string_literal: true

# https://github.com/puppetlabs/puppet-specifications/blob/master/language/func-api.md#the-4x-api
Puppet::Functions.create_function(:'platform::domain_configured') do
  dispatch :domain_configured do
    param 'Hash', :domain_settings
  end

  def domain_configured(domain_settings)
    required_keys = ['ensure', 'controller', 'mgmt_user', 'mgmt_pass', 'computer_name']
    required_keys.all? { |key| domain_settings.key?(key) }
  end
end

