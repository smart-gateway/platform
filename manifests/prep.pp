# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::prep
class platform::prep {

  # Ensure that the package manager has been updated so installs don't fail on new systems
  platform::utils::update_package_manager { 'platform::ensure_package_manager_is_updated': }

}
