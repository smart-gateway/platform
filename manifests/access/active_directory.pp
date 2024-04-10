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
    # Join system to the domain if not already joined
    if !$facts['joined_to_domain'] {
      $domain_name = platform::dn_to_domain($domain_settings['domain_dn'])
      $domain_name_upper = upcase($domain_name)

      exec { 'join-domain':
        command => "echo '${mgmt_pass.unwrap}' | realm join ${controller} --user=${mgmt_user.unwrap} --computer-name=${computer_name}",
        unless  => "realm list | grep -q '${domain_name}'",
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      }
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
      content => epp('platform/domain/etc/sssd/sssd.conf.epp', {
          'domain_controller' => $controller,
          'domain_name_lower' => $domain_name,
          'domain_name_upper' => $domain_name_upper,
          'computer_name'     => $computer_name,
      }),
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    }

    file { '/etc/krb5.conf':
      ensure  => file,
      content => epp('platform/domain/etc/krb5.conf.epp', {
          domain_name_upper => $domain_name_upper,
      }),
    }

    service { 'sssd':
      ensure    => running,
      enable    => true,
      subscribe => [
        File['/etc/sssd/sssd.conf'],
        File['/etc/krb5.conf'],
      ],
    }

    service { 'sshd':
      ensure    => running,
      enable    => true,
      subscribe => File_line['AuthorizedKeysCommand'],
    }

    # Setup access.conf file
    $users = $platform::users
    $users.each | $username, $details | {
      $type = get($details, 'type', 'local')
    }
    $local_users = $users.filter | $username, $details | {
      $details['type'] == 'local'
    }.keys

    file { '/etc/security/access.conf':
      ensure  => file,
      content => epp('platform/domain/etc/security/access.conf.epp', {
          'local_users'   => $local_users,
          'host_group'    => "users-${computer_name}",
          'project_group' => "users-${platform::project_id}",
      }),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    # Ensure that the config file is being used for access
    -> file_line { 'enable /etc/security/access.conf in /etc/pam.d/common-account':
      ensure  => present,
      path    => '/etc/pam.d/common-account',
      line    => 'account  required       pam_access.so',
      match   => '^account\s+required\s+pam_access\.so',
      replace => false,
    }
  } elsif $ensure == 'absent' {
    if $facts['joined_to_domain'] {
      Notify { "Leaving ${controller}": }
      exec { 'leave-domain':
        command => 'realm leave',
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      }
    }
  } else {
    fail('Unknown ensure value')
  }

  #%CAPABILITIES%
  # join a domain
  # leave a domain
  # configure sssd
  #  - configure sssd.conf
  #  - setup ad authorized sudo access
  # configure ssh
  # configure access.conf
  #  - add local users
  #  - add host specific group
  #  - add project specific group
  #%END%

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
