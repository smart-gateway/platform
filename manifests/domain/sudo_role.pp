# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::domain::sudo_role { 'namevar': }
define platform::domain::sudo_role (
  Enum['present', 'absent'] $ensure,
  String[1] $role_name,
  String[1] $path,
  String[1] $sudo_host,
  String[1] $sudo_user,
  String[1] $sudo_command = 'ALL',
) {
  if $ensure == 'present' {
    Notify { "creating sudo role ${role_name}": }
    exec { "create-${role_name}":
      command   => "New-ADObject -Name '${role_name}' -Path '${path}' -Type sudoRole -OtherAttributes @{sudoCommand='${sudo_command}'; sudoHost='${sudo_host}'; sudoUser='${sudo_user}'}",
      provider  => powershell,
      unless    => "Get-ADObject -Filter 'Name -eq \"${role_name}\"' -SearchBase '${path}'",
      logoutput => true,
    }
  } elsif $ensure == 'absent' {
    exec { "remove-${role_name}":
      command   => "Remove-ADObject -Identity '${role_name}' -Confirm:\$false",
      provider  => powershell,
      onlyif    => "Get-ADObject -Filter 'Name -eq \"${role_name}\"' -SearchBase '${path}'",
      logoutput => true,
    }
  }
}
