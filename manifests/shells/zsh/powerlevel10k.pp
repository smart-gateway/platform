# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::zsh::powerlevel10k { 'namevar': }
define platform::shells::zsh::powerlevel10k (
  Enum['present', 'absent', 'installed', 'latest', 'purged'] $ensure,
  String $user,
  String $home,
) {
}
