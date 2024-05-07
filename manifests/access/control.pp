# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::access::control
class platform::access::control (
  Optional[Hash] $domain_settings = {},
  String $allow_password_over_ssh,
) {
  # Ensure domain control if domain is fully configured
  if platform::domain_configured($domain_settings) {
    class { 'platform::access::active_directory':
      domain_settings         => $domain_settings,
      allow_password_over_ssh => $allow_password_over_ssh,
    }
  }
}
