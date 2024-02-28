# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::user::control
class platform::user::control (
  String $managed_startup_scripts_user_dir,
  Boolean $manage_home_default = true,
  Hash $users = {},
) {
  $platform::users.each | $username, $details | {
    # Get the manage_home value from the user or use the default
    $manage_home = $details[managehome] == undef ? {
      true    => $manage_home_default,
      default => $details[managehome],
    }

    # Handle based on type of user entry
    $type = get($details, 'type', 'local')
    case $type {
      'local': {
        # local user account
        platform::user::local { "create-local-user-${username}":
          username                         => $username,
          details                          => $details,
          manage_home                      => $manage_home,
          managed_startup_scripts_user_dir => $managed_startup_scripts_user_dir,
        }
      }
      'domain': {
        # domain user account
        platform::user::domain { "create-domain-user-${username}":
          username                         => $username,
          details                          => $details,
          manage_home                      => $manage_home,
          managed_startup_scripts_user_dir => $managed_startup_scripts_user_dir,
        }
      }
      default: {
        fail("invalid user type: ${type} for user ${username}")
      }
    }
  }
}
