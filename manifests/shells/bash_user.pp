# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::bash { 'namevar': }
define platform::shells::bash_user (
  Boolean $manage_startup_scripts = true,
  Hash $shell_options = {},
) {
  # Setup startup scripts
  if $manage_startup_scripts {
  }
}
