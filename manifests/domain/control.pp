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
) {
  # Ensure that this system is a domain controller
  if $facts['is_domain_controller'] {
    # Ensure the OUs for the users and groups is created
    $ou_components = $users_ou.split(/,OU=/).reverse
    $current_path = $domain_dn

    $ou_components.each | $ou | {
      $full_dn = "OU=${ou},${current_path}"

      dsc_adorganizationalunit { "ensure ${full_dn} is created":
        dsc_ensure => 'present',
        dsc_name   => $ou,
        dsc_path   => $current_path,
      }

      $current_path = $full_dn
    }

    # # Ensure the
    # dsc_adorganizationalunit { 'ensure_groups_ou':
    #   dsc_ensure => 'present',
    #   dsc_name   => $group_name,
    #   dsc_path   => $domain_dn,
    # }
  }

  #         ADOrganizationalUnit 'ExampleOU'
  #       {
  #           Name                            = $Name
  #           Path                            = $Path
  #           ProtectedFromAccidentalDeletion = $ProtectedFromAccidentalDeletion
  #           Description                     = $Description
  #           Ensure                          = 'Present'
  #       }
}
