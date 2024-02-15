# Class: platform::users
#
# This class manages user accounts on the system. It allows for the creation and management
# of user accounts based on a provided hash of user details. Additionally, it offers the option
# to manage the home directories for these user accounts.
#
# Parameters:
#   - users: A hash where each key represents a username with its value being a hash of user attributes.
#            The user attributes hash example is shown below with comments. The below example is hiera
#            however these values could be used in creation of a hash directly in manifest code also.
#            Example:
#               users:
#                 username:
#                   ensure: present or absent
#                   comment: [optional] comment for the user account
#                   password: salted sha512 crypt [ to generate: python -c 'import crypt; print(crypt.crypt("somesecret", crypt.mksalt(crypt.METHOD_SHA512)))' ]
#                   groups: [optional] array of groups in which the user has membership
#                   shell: [optional | default bash] users preferred shell - supported are 'bash', 'zsh', and 'sh'
#                   managehome: [optional | default yes] set to yes or no and controls if Puppet should create and remove the home directory when the user is created and removed
#                   has-files: false
#                   keys: [optional] hash
#                     hash_key_name:
#                       key_type: ed25519 or rsa
#                       key_value: <ssh_key_value>
#   - manage_home: A boolean value that determines the default value for managing the home directories for the user accounts.
#                  If set to true, Puppet will ensure that the home directories are created or removed as needed,
#                  based on the user's ensure attribute. Defaults to true.
#
# Usage:
#   To use this class, declare it in your manifest with the desired parameters. For example:
#
#     class { 'platform::users':
#       users => {
#         'johndoe' => { 'ensure' => 'present', 'uid' => '1001', 'shell' => '/bin/bash', 'home' => '/home/johndoe' },
#         'janedoe' => { 'ensure' => 'present', 'uid' => '1002', 'shell' => '/bin/zsh', 'home' => '/home/janedoe' },
#       },
#       manage_home => true,
#     }
#
# Note:
#   Ensure that the provided user details match the expected format and that the specified attributes
#   are valid for the user resource type. The manage_home parameter should be carefully considered in
#   environments where home directory management is handled externally or where special configurations
#   are required.
class platform::users(
  Hash $users = {},
  Boolean $manage_home = true,
) {
}
