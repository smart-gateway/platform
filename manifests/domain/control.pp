# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::domain::control
class platform::domain::control (
  String $domain_dn = 'DC=jointpathfinding,DC=com',
  String $user_dn = "CN=Users,${domaindn}",
  String $group_name = 'Groups',
  String $sudoers_name = 'sudoers',
) {
  # Ensure that this system is a domain controller
  dsc_adorganizationalunit { 'ensure_groups_ou':
    dsc_ensure => 'present',
    dsc_name   => $group_name,
    dsc_path   => $domain_dn,
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
