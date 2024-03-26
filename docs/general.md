# General Module Details

## Module overview

- Primary entrypoint into module is `init.pp` which sets up ordering of execution.
- Entrypoint to module subsystems is always `<subsystem_name>/control.pp` for example `user/control.pp`.

## Functions

This module handles the following tasks under the following categories.

### Users
- Add/Remove local users
- Add/Remove domain users
- Control users group membership
- Control users authorized keys
- Control import of authorized keys from GitHub or Launchpad
- Ensure creation of arbitrary user files based on source file (puppet, https)
- Configure shell addons - oh-my-zsh, powerlevel10k, zsh plugins

### Domain
- Join/Leave domain

## Facts

The following custom facts are added by this module.

#### home_directories

This fact creates an array which contains a list of all of the home directories currently on the system. This is used 
to control setup of shell startup scripts only for users who have home directories on the system. The reason for this
is to prevent the creation of folders for every domain user on every system.

```ruby
Facter.add(:home_directories) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    Dir.entries('/home').select { |entry|
      File.directory?(File.join('/home', entry)) && !(entry == '.' || entry == '..')
    }.map { |entry| "/home/#{entry}" }
  end
end
```



#### SSH Configuration

The configuration of `ssh` can be managed at many different levels of the hierarchy starting with the `default.yaml` file which applied
globally to the platform. This will set the default behavior for ssh configurations. Then if you need to modify them on a more granular
level you can do so at the `data\clusters` level or `data\nodes` level.

```yaml
ssh:
    allow_password: string                  # yes | no - allow users to use passwords via ssh
```

#### Package Configuration

The configuration of `packages` can be managed at many different levels also. `default.yaml` will control the platform wide packages to ensure are present or absent then you can be more specific based on `data\os`, `data\clusters` or `data\nodes`

```yaml
packages:
    package_name:                           # name of the package
        ensure: string                      # installed | uninstalled - desired state of the package
```

#### Domain Configuration

The configuration of `domain` should only be at the `default.yaml` level as it is something that should apply globally for the platform. Technically support for more narrow definition such as in `data\clusters` is supported if there were a case of a different active directory server for a specific project but this has not been the case to date.

```yaml
domain:
    controller: string                                  # dc01.jointpathfinding.com - fqdn of the domain controller
    mgmt_user: string                                   # account for joining systems, creating accounts etc
    mgmt_pass: string                                   # password for joining the system to the domain
```

This portion of the domain hash should always be in a `eyaml` file so as to protect the username and password being used.
For example:

```yaml
---
domain:
  controller: dc01.jointpathfinding.com
  mgmt_user: ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEAgtpMPrKnNIp4GcF3XH85mOxMqDyK/CQx8CzPeektlt0NkWb5GsAGPBllq2vlnQKdfZrf2tfXDcrN7/f9jIj9n8AFYdnlf045je7e0p/bVIfOTVM7kp3/kk42MXsnqRF4qwg/V+/9iMkV9BTP6ku0qjJ+kByuKMaDii/xKAal6eUA3Ndol8phzkkKBRAzzrG0YOBCBHxRw2hWAIuttAUls11eVtvRi8pouY79K7YhOS9Qu0sSL3NRhKLHxZfoAIv3fslGjY5SCVZYvkX3KK8L6JURSMYhyhQXxSOUhqEMW60kcu5SBpvvtBDCYWuyf3J/8NuzDY4/RIMgY6zVuLpv9TA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBAeLqf3GtN9bIbTX1HL/2MQgBDF0zezXVd7e36/WtSlirzB]
  mgmt_pass: ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEAHCUojXUvi2ayvZZUljhXO2Aj3EH7o1ydhrV3KLbOs7P5+RfnTx+8IPE/7MRIcuJ1uXGomeYU6VgVRZ42bQ/ibpmqe4ZavkYeJktTuV9gqyFqqhGCTnmpZeB5nXI1t+ZDjC5JJpnFuWmsxBx0vLq1EFZsSWYGCLFjJUWeHWoe7Hz9BxoF4Qp2SivLExtcp9iu8Qe6O4IqYQdalfUmqtigkggHA0TNxIGGeADOV43pQRuWbUSTERZ5OoKU0R5WqThD3KUFpzGdlMx9+Cy0RbZjSqSdQR78ctqbrAyb1hKYcVDUvHYkEQgzckig75Q/OtEABXvRXyzAr/ZMeNH7lgFOfDA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBAWKuWQnagV+v+uqb4yMmo1gBCYzZ1x/WgL6wB3nkcpiV8h]
```