# General Module Details

## Module overview

- Primary entrypoint into module is `init.pp` which sets up ordering of execution.
- Entrypoint to module subsystems is always `<subsystem_name>/control.pp` for example `user/control.pp`.

## Functions

## Facts

The following custom facts are added by this module.

#### home_directories
```ruby
Facter.add(:home_directories) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    Dir.entries('/home').select { |entry|
      File.directory?(File.join('/home', entry)) && !(entry == '.' || entry == '..')
    }
  end
end
```

### Users
- Add/Remove local users
- Add/Remove domain users
- Control users group membership
- Control users authorized keys
- Control import of authorized keys from GitHub or Launchpad
- Ensure creation of arbitrary user files based on source file (puppet, https)
- Configure shell addons - oh-my-zsh, powerlevel10k, zsh plugins

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
    mgmt_pass: string                                   # TODO: need to figure out a secure way to handle this
```