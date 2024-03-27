# Migration

## New Packages


## Hiera Changes

#### Changes to common.yaml

Add the following packages to support domain joining functionality built into the platform module.

```yaml
  sssd-ad:
    ensure: installed
  sssd-tools:
    ensure: installed
  realmd:
    ensure: installed
  adcli:
    ensure: installed
  libsss-sudo:
    ensure: installed
```

#### Changes to hiera.yaml

```yaml
# Add new user data folder to data/users then add the following entry to hiera.yaml
# ---------------------------------------------------------------------------------
# Data for users
- name: "User Data"
  glob: "users/*.yaml"

# Remove old Operating System Specific Data section
# ---------------------------------------------------------------------------------
# REMOVE THIS FROM EXISTING
- name: "Operating System Specific Data"
  path: "os/%{facts.os.name}.yaml"

# Replace with Operating System and Version specific Data
# ---------------------------------------------------------------------------------
# Data specific to os and version such as package names and versions
- name: "Operating System and Version Specific Data"
  path: "os/%{facts.os.name}_%{facts.os.release.major}.yaml"


# Remove old encrypted yaml sections
# ---------------------------------------------------------------------------------
# REMOVE THIS FROM EXISTING   
  - name: "Per-Project Secret data (encrypted)"
    lookup_key: eyaml_lookup_key
    path: "secrets/%{facts.whereami}.eyaml"
    options:
      pkcs7_private_key: /etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem
      pkcs7_public_key: /etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem

# Replace with common encrypted data
# ---------------------------------------------------------------------------------
  # Encrypted common platform data
  - name: "Encrypted common data"
    lookup_key: eyaml_lookup_key
    path: "secrets/common.eyaml"
    options:
      pkcs7_private_key: /etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem
      pkcs7_public_key: /etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem

```

#### Changes inside of data directory

1. Updated `users` format
2. Migrate users from `default.yaml` to `data\users\<username>.yaml` files instead
3. Migrate packages that are specific to versions of the OS such as fzf from the `default.yaml` file to an os specific one.

#### Setup of encrypted hiera

1. Install the gem on the Puppet Server

```
gem install hiera-eyaml
```

2. Create directory for kes

```
sudo mkdir -p /etc/puppetlabs/puppet/eyaml/
```

3. Generate the keys

```
eyaml createkeys \
  --pkcs7-private-key=/etc/puppetlabs/eyaml/private_key.pkcs7.pem \
  --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem

```

4. Ensure proper permissions

```
chown -R puppet:puppet /etc/puppetlabs/puppet/eyaml/
chmod 0500 /etc/puppetlabs/puppet/eyaml/
chmod 0400 /etc/puppetlabs/puppet/eyaml/*.pem
```

5. Encrypt values to place in the `common.eyaml` file with the command below. You can also run this command on your development workstation by installing the gem above and then copying the `public` key only to your workstation. 

```
eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -s 'Administrator'
# this will produce an output like this whcih can be placed as a value in the encrypted hiera file.
string: ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEASPBpLJL61tAGUVnzyG1Qhib84hs+snj3jGKjuqz5d9ulGMhIZz9ogFc9ZU37SYpgDCS1yEtDuULaJY/PAuMMnvQle+LZPDPqn7qQyzDK5cMlapO+ay+bX2yKF9fpDy0TkesLkFZsEpy7l69pbOtxUD/YvK4nN4Ca+5/uEzhTYxJ7z9kFkITdxwrEJcLvj/b2+EyiklDXsWKCsTYyjyyy4doa8WLh7mIORNRy0eYm5BFTvywnI86w9lVanqZy8GSzBpRNSwKqHXfkwLhc/wmnlBG5V5x13rvPBzOSzUQRSP8DyGZiFxhQT0z1+lx/mO2CkePYElnfGwfJBz+oyYrsoDA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBAnm5XMrf0Jf7e4/RKNhggMgBBA1ey5YZKzdFegksw+EMjR]

OR

block: >
  ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBAD
  AFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEASPBpLJL61tAGUVnzyG1Qhib84h
  s+snj3jGKjuqz5d9ulGMhIZz9ogFc9ZU37SYpgDCS1yEtDuULaJY/PAuMMnv
  Qle+LZPDPqn7qQyzDK5cMlapO+ay+bX2yKF9fpDy0TkesLkFZsEpy7l69pbO
  txUD/YvK4nN4Ca+5/uEzhTYxJ7z9kFkITdxwrEJcLvj/b2+EyiklDXsWKCsT
  Yyjyyy4doa8WLh7mIORNRy0eYm5BFTvywnI86w9lVanqZy8GSzBpRNSwKqHX
  fkwLhc/wmnlBG5V5x13rvPBzOSzUQRSP8DyGZiFxhQT0z1+lx/mO2CkePYEl
  nfGwfJBz+oyYrsoDA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBAnm5XMrf
  0Jf7e4/RKNhggMgBBA1ey5YZKzdFegksw+EMjR]
```

## Control Repo Changes

1. All files that use the `/tmp/puppet-agent/...` for recording applied profiles and roles need to switch to using the `platform::utils::mark_applied` defined type
2. `site.pp` needs to be updated to the below contents to support Windows and Linux

```puppet
# OS specific variables  
$managed_file_path = $facts['os']['family'] ? {  
  'windows' => 'C:/managed_by_puppet.txt',  
  default   => '/managed_by_puppet.txt'  
}  
  
$owner = $facts['os']['family'] ? {  
  'windows' => 'Administrator',  
  default   => 'root'  
}  
  
$group = $facts['os']['family'] ? {  
  'windows' => 'None',  
  default   => 'root'  
}  
  
$base_path = $facts['os']['family'] ? {  
  'windows' => 'C:/puppet-agent/',  
  default   => '/tmp/puppet-agent/'  
}  
  
# Notice file  
file { $managed_file_path:  
  ensure  => file,  
  mode    => '0444',  
  owner   => $owner,  
  group   => $group,  
  content => '[NOTICE] This system is under managent by Puppet.',  
}  
  
# Base directory  
file { $base_path:  
  ensure => directory,  
  mode   => '0755',  
  owner  => $owner,  
  group  => $group,  
}  
  
# Applied directory  
file { "${base_path}applied":  
  ensure => directory,  
  mode   => '0755',  
  owner  => $owner,  
  group  => $group,  
}  
  
# README file  
file { "${base_path}applied/README.txt":  
  ensure  => file,  
  mode    => '0444',  
  owner   => $owner,  
  group   => $group,  
  content => '[NOTICE] The profiles listed here are only valid after a fresh reboot and Puppet run, otherwise there may be stale values here',  
}  
```

3. Remove `facts.txt` file from `base.pp` as it shouldn't be needed with users able to run facter instead to see facts

```puppet
  file { '/tmp/puppet-agent/facts.txt':
    ensure  => file,
    mode    => '0444',
    owner   => 'root',
    group   => 'root',
    content => "cluster: ${cluster}\nproject: ${project}\n",
  }
```

4. New `role::domain_controller` which is applied to the DC(s) to help them manage the users/configuration of the domain

```puppet

```