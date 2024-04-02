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
  Hash $projects = {},
  String $private_key_b64 = '',
) {
  # Ensure that this system is a domain controller
  if $facts['is_domain_controller'] {
    # # Ensure long paths are enabled
    # registry::value { 'LongPathsEnabled':
    #   key  => 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
    #   type => dword,
    #   data => '1',
    # }

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

    # Handle creation of all users that are of type=domain
    $users_path = "${users_ou},${domain_dn}"
    $domain = platform::dn_to_domain($domain_dn)
    $users.each | $username, $details | {
      $type = $details['type'] ? {
        'domain' => 'domain',
        default  => 'other'
      }

      if $type == 'domain' {
        $user_pass = Sensitive(platform::decrypt_password($private_key_b64, $details['password']))
        dsc_aduser { "ensure ${username} is created in domain":
          dsc_ensure            => $details['ensure'],
          dsc_username          => $username,
          dsc_userprincipalname => "${username}@${domain}",
          dsc_domainname        => $domain,
          dsc_givenname         => $details['firstname'],
          dsc_surname           => $details['lastname'],
          dsc_company           => $details['company'],
          dsc_description       => $details['comment'],
          dsc_displayname       => "${details['lastname']}, ${details['firstname']}",
          dsc_emailaddress      => $details['email'],
          dsc_path              => $users_path,
          dsc_password          => {
            user     => $username,
            password => $user_pass,
          },
        }
      }
    }

    Notify { "Projects: ${projects}": }
    # Handle creation of all projects
    $projects.each | $project_name, $project_details | {
      $project_id = sprintf('%03d', $project_details['id'])
      Notify { "Project: ${project_name} - ${project_details}": }

      $standard_groups = {
        "Admins-${project_id}" => $project_details['access']['admins'],
        "Users-${project_id}" => $project_details['access']['users'] + ["Admins-${project_id}"],
      }

      $has_custom_groups = $project_details['access'] and $project_details['access']['custom']
      $custom_groups = $has_custom_groups ? {
        true  => platform::process_custom_groups($project_details['access']['custom']),
        false => {},
      }

      $groups_to_create = merge($standard_groups, $custom_groups)
      $groups_path = "${groups_ou},${domain_dn}"

      $groups_to_create.each | $group_name, $group_members | {
        # Create the active directory group
        dsc_adgroup { "ensure ${project_name} group ${group_name} exists":
          dsc_ensure           => 'present',
          dsc_groupname        => $group_name,
          dsc_groupscope       => 'global',
          dsc_category         => 'security',
          dsc_path             => $groups_path,
          dsc_memberstoinclude => $group_members,
        }
      }

      # Create standard sudo control objects
      $sudoers_path = "${sudoers_ou},${domain_dn}"
      platform::domain::sudo_role { "ensure ${project_name} standard sudo role":
        ensure       => 'present',
        role_name    => "Admins-${project_id}",
        path         => $sudoers_path,
        sudo_host    => "*.${project_name}.${domain}",
        sudo_user    => "%Admins-${project_id}",
        sudo_command => 'ALL',
      }

      $custom_admin_groups = $custom_groups.keys.filter |String $key| { $key =~ /^Admin-/ }
      $custom_admin_groups.each | $admin_group | {
        $host_portion = split($admin_group, 'Admins-')[1]
        $host = downcase($host_portion)
        platform::user::sudo_role { "ensure ${project_name} sudo role ${admin_group}":
          ensure       => 'present',
          role_name    => $admin_group,
          path         => $sudoers_path,
          sudo_host    => "${host}.${project_name}.${domain}",
          sudo_user    => "%${admin_group}",
          sudo_command => 'ALL',
        }
      }
    }
  }
}
