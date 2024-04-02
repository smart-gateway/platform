# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::domain::sudo_role { 'namevar': }
define platform::domain::sudo_role (
  Enum['present', 'absent'] $ensure,
  String[1] $name,
  String[1] $path,
  String[1] $sudo_host,
  String[1] $sudo_user,
  String[1] $sudo_command = 'ALL',
) {
  if $ensure == 'present' {
    exec { "create-${name}":
      command   => "New-ADObject -Name '${name}' -Path '${path}' -Type sudoRole -OtherAttributes @{sudoCommand='${sudo_command}'; sudoHost='${sudo_host}'; sudoUser='${sudo_user}'}",
      provider  => powershell,
      unless    => "Get-ADObject -Filter 'Name -eq \"${name}\"' -SearchBase '${path}'",
      logoutput => true,
    }
  } elsif $ensure == 'absent' {
    exec { "remove-${name}":
      command   => "Remove-ADObject -Identity '${name}' -Confirm:\$false",
      provider  => powershell,
      onlyif    => "Get-ADObject -Filter 'Name -eq \"${name}\"' -SearchBase '${path}'",
      logoutput => true,
    }
  }
}
