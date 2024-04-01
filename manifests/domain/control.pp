# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::domain::control
class platform::domain::control (
  String $domain_dn = 'DC=jointpathfinding,DC=com',
  String $users_ou = 'OU=Users,OU=Research',
  String $groups_ou = 'OU=Groups,OU=Research',
  String $sudoers_ou = 'OU=sudoers',
  Hash $users = {},
) {
  # Ensure that this system is a domain controller
  if $facts['is_domain_controller'] {
    # Ensure long paths are enabled
    registry::value { 'LongPathsEnabled':
      key  => 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
      type => dword,
      data => '1',
    }

    # Ensure the OUs for the users and groups is created
    $ous = {
      'users' => $users_ou,
      'groups' => $groups_ou,
      'suoders' => $sudoers_ou,
    }

    $ous.each | $name, $ou_dn | {
      $ou_list = platform::parse_ou_path($ou_dn)

      $ou_list.each | $ou | {
        $full_path = regsubst("${ou['path']},${domain_dn}", '^\s*,\s*', '')

        dsc_adorganizationalunit { "ensure ${name} ou: ${ou['name']},${full_path} is created":
          dsc_ensure => 'present',
          dsc_name   => $ou['name'],
          dsc_path   => $full_path,
        }
      }
    }

    # Handle creation of all projects

    # Handle creation of all users that are of type=domain
    $users_path = "${users_ou},${domain_dn}"
    $users.each | $username, $details | {
      $type = $details['type'] ? {
        'domain' => 'domain',
        default  => 'other'
      }

      if $type == 'domain' {
        dsc_aduser { "ensure ${username} is created in domain":
          dsc_ensure       => $details['ensure'],
          dsc_username     => $username,
          dsc_givenname    => $details['firstname'],
          dsc_surname      => $details['surname'],
          dsc_company      => $details['company'],
          dsc_description  => $details['comment'],
          dsc_displayname  => "${details['lastname']}, ${details['firstname']}",
          dsc_emailaddress => $details['email'],
          dsc_path         => $users_path,
        }
      }
    }

    # Handle creation of all sudoers groups for each project and setting of the attributes

    # Handle adding users to the proper groups

    # Handle nesting of groups
  }
}
