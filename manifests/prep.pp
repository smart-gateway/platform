# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::prep
class platform::prep {

  # Do pre-install tasks
  platform::utils::update_package_manager { 'platform::ensure_package_manager_is_updated': }

}
