# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::domain::control
class platform::domain::control (
  Enum['yes', 'present', 'joined', 'no', 'absent', 'left'] $ensure = 'joined',
  String $join_user,
  String $join_pass,
  String $computer_name,
  Optional[String] $domain_controller = 'dc01.jointpathfinding.com',
) {
  # pp_cluster: cluster name
  # pp_instance_id: project id number
  # pp_project: project name
}
