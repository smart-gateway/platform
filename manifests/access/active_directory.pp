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
  $computer_name = get($domain_settings, 'computer_name', '')

  if $ensure == 'joined' {
    Notify { "Joining ${controller} as ${computer_name}": }
    if !facts['joined_to_domain'] {
      exec { 'join-domain':
        command => "echo '${mgmt_pass}' | realm join ${controller} --user=${mgmt_user} --computer-name=${computer_name}",
        unless  => "realm list | grep -q '${pdc}'",
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      }

      file_line { 'AuthorizedKeysCommand':
        path               => '/etc/ssh/sshd_config',
        line               => 'AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys',
        match              => '^AuthorizedKeysCommand\s+',
        append_on_no_match => true,
      }

      file_line { 'AuthorizedKeysCommandUser':
        path               => '/etc/ssh/sshd_config',
        line               => 'AuthorizedKeysCommandUser nobody',
        match              => '^AuthorizedKeysCommandUser\s+',
        append_on_no_match => true,
      }

      file_line { 'pam_mkhomedir':
        path               => '/etc/pam.d/common-session',
        line               => 'session optional    pam_mkhomedir.so skel=/etc/skel umask=077',
        match              => 'pam_mkhomedir.so',
        append_on_no_match => true,
      }

      file { '/etc/sssd/sssd.conf':
        ensure  => file,
        content => epp('mymodule/sssd.conf.epp', { 'domain_controller' => $controller }),
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
      }

      service { 'sssd':
        ensure    => running,
        enable    => true,
        subscribe => Exec['join-domain'],
      }

      service { 'sshd':
        ensure    => running,
        enable    => true,
        subscribe => File_line['AuthorizedKeysCommand'],
      }
    }
  } elsif $ensure == 'absent' {
    if facts['joined_to_domain'] {
      Notify { "Leaving ${controller}": }
      exec { 'leave-domain':
        command => "realm leave --user=${mgmt_user}",
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      }
    }
  } else {
    fail('Unknown ensure value')
  }

  # === FILES OF INTEREST WHEN JOINED TO THE DOMAIN ===
  # sssd.conf
  # krb5.conf
  # nsswitch.conf
  # pam.d/common-account
  # pam.d/common-auth
  # pam.d/common-password
  # pam.d/common-session
  # pam.d/common-session-noninteractive
  # pam.d/other
  # pam.d/sudo
  # sssd.conf
  # sssd.conf.d
  # sssd.conf.d/README
  # sssd.conf.d/dbus.conf
  # sssd.conf.d/sssd-ad.conf
  # sssd.conf.d/sssd-ldap.conf
  # sssd.conf.d/sssd-proxy
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
