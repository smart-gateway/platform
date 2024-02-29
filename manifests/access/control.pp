# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::access::control
class platform::access::control (
  Optional[Hash] $domain_settings = {},
) {
  # Check if domain settings are passed
  notify { "domain_settings: ${domain_settings}": }
  if !empty($domain_settings) {
    class { 'platform::access::active_directory':
      domain_settings => $domain_settings,
    }
  }
}
