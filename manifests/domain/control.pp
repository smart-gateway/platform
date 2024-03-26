# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::domain::control
class platform::domain::control (
  Hash $domain_settings,
) {
  # pp_cluster: cluster name
  # pp_instance_id: project id number
  # pp_project: project name

  $ensure = get($domain_settings, 'ensure', undef)
  $controller = get($domain_settings, 'controller', '')
  $mgmt_user = Sensitive(get($domain_settings, 'mgmt_user', ''))
  $mgmt_pass = Sensitive(get($domain_settings, 'mgmt_pass', ''))

  case $ensure {
    'joined', 'installed', 'present': {
      # Do something
    }
    'left', 'unjoined', 'absent': {
      # Do something else
    }
    default: {
      warning("Invalid value for \$ensure: ${ensure}")
    }
  }
}
