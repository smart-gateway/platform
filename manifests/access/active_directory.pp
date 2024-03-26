# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::access::active_directory
class platform::access::active_directory (
  Hash $domain_settings,
) {
  $ensure = get($domain_settings, 'ensure', undef)
  $controller = get($domain_settings, 'controller', '')
  $mgmt_user = Sensitive(get($domain_settings, 'mgmt_user', ''))
  $mgmt_pass = Sensitive(get($domain_settings, 'mgmt_pass', ''))




  notify { "Ensure: ${ensure} | DC: ${controller} | User: ${mgmt_user} | Pass: ${mgmt_pass}": }
}
# /etc/default/locale
# /etc/environment
# /etc/group
# /etc/host.conf
# /etc/hosts
# /etc/ld.so.cache
# /etc/localtime

# NOTE: has settings like logging successful login events, home dir permissions, password aging etc
# /etc/login.defs
# /etc/nsswitch.conf
# /etc/pam.d/common-account
# /etc/pam.d/common-auth
# /etc/pam.d/common-password
# /etc/pam.d/common-session
# /etc/pam.d/common-session-noninteractive
# /etc/pam.d/other
# /etc/pam.d/sudo
# /etc/passwd
# /etc/resolv.conf
# /etc/security/capability.conf

# NOTE: limit users items on the system, can be things like cpu time, stack, memory, chroot, nice etc
# /etc/security/limits.conf
# /etc/security/limits.d
# /etc/security/pam_env.conf
# /etc/shadow
# /etc/sssd/sssd.conf
# /etc/sudo.conf
# /etc/sudoers
# /etc/sudoers.d
# /etc/sudoers.d/90-cloud-init-users
# /etc/sudoers.d/README
# /etc/userdb}
