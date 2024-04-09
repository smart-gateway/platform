# platform module

Welcome to your new module. A short overview of the generated parts can be found
in the [PDK documentation][1].

The README template below provides a starting point with details about what
information to include in your README.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with platform](#setup)
    * [What platform affects](#what-platform-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with platform](#beginning-with-platform)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Briefly tell users why they might want to use your module. Explain what your
module does and what kind of problems users can solve with it.

This should be a fairly short description helps the user decide if your module
is what they want.

## Setup

### What platform affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For
example, folks can probably figure out that your mysql_instance module affects
their MySQL instances.

If there's more that they should know about, though, this is the place to
mention:

* Files, packages, services, or operations that the module will alter, impact,
  or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
another module, etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you might want to include an additional "Upgrading" section here.

### Beginning with platform

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most basic
use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your
users how to use your module to solve problems, and be sure to include code
examples. Include three to five examples of the most important or common tasks a
user can accomplish with your module. Show users how to accomplish more complex
tasks that involve different types, classes, and functions working in tandem.

### Important Notes

1. Puppet configuration on Windows and Linux needs an extra section that we haven't previously provisioned. This section is the `user` section which controls the other puppet tools and commands. This includes plugin downloads.

```text
...existing sections [agent] and [server]...
[user]
server = puppet.example.com
certname = <certname>
```

### Features

#### platform

- [x] General
  - [x] Encrypted Hiera Support
  - [x] Domain Information
  - [x] Project Information
- [ ] System Basics
  - [x] Configure Timezone
  - [ ] Configure NTP
  - [ ] Configure DNS
  - [x] Hosts File Manipulation
- [ ] Networking
  - [ ] Configure Network Interfaces
  - [ ] Configure Network Routing
- [ ] Remote Management
  - [ ] SSH Configuration
  - [ ] RDP Configuration
  - [ ] WinRM Configuration
  - [ ] IPMI Configuration
  - [ ] IPMI User Management
  - [ ] IPMI Enablement
  - [ ] IPMI Disablement
- [x] User Management
  - [x] Create Local Users
    - [x] Configure Users Shell
    - [x] Configure Shell Extensions
    - [x] Provision SSH Keys
        - [x] Provision SSH Keys from Hiera
        - [x] Provision SSH Keys from GitHub or LaunchPad
    - [x] Provision Arbitrary Files
  - [x] Create Domain Users
    - [ ] Configure Users Shell
    - [x] Configure Shell Extensions
    - [ ] Provision SSH Keys
        - [ ] Provision SSH Keys from Hiera
        - [ ] Provision SSH Keys from GitHub or LaunchPad
    - [x] Provision Arbitrary Files
- [x] Access Control
  - [x] Join Domain
  - [x] Configure Access Control
    - [x] Support Per-Project Access
    - [x] Support Per-System Access
  - [x] Configure Sudo Access
    - [x] Support Per-Project Sudo
    - [x] Support Per-System Sudo
- [ ] Firewall
  - [ ] Configure iptables
  - [ ] Configure nftables
- [ ] Monitoring
    - [ ] Node Exporter
- [ ] Logging
    - [ ] Command Execution Logging
- [x] Tools
  - [x] Netcheck
- [x] Facts
  - [x] Domain Joined
  - [x] Domain Information
  - [x] Home Directories
  - [x] Domain Controller
  - [x] Sudo Roles
- [ ] DNS

#### platform::domain

- [x] Users
  - [x] Create New Users
  - [x] Delete Users
- [x] Groups
  - [x] Create New Groups
  - [x] Delete Groups
  - [x] Add Users to Groups
  - [x] Add Groups to Groups
- [x] Organizational Units
  - [x] Create New Organizational Units
  - [x] Delete Organizational Units
- [x] Sudo
  - [x] Create New Sudo Roles
  - [x] Configure Sudo Role Groups
  - [x] Configure Sudo Role Commands
  - [x] Configure Sudo Role Hosts
- [ ] Domain Name Services
  - [ ] Create new DNS Records
  - [ ] Delete DNS Records

#### platform::<need_to_be_sorted_still>

- [ ] WEMO
  - [ ] WEMO Install
  - [ ] WEMO Configuration
  - [ ] WEMO Rule Manipulation
- [ ] System Deployment
  - [ ] MAAS
  - [ ] Virtualization
    - [ ] Libvirt
    - [ ] LXD
- [ ] Switch Management
  - [ ] Cisco Switch Configuration
  - [ ] Whitebox Switch Configuration
  - [ ] OVS
    - [ ] OVS Install
    - [ ] OVS Configuration
- [ ] GitHub Runners
  - [ ] Deploy GitHub Runner
  - [ ] Configure GitHub Runner
  - [ ] Deploy Secrets
- [ ] Puppet Server
  - [ ] Configure Puppet Server
  - [ ] Deploy Control Repo
  - [ ] Create GitHub Runner
  - [ ] Configure Pipelines
  
## Reference

This section is deprecated. Instead, add reference information to your code as
Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your
module. For details on how to add code comments and generate documentation with
Strings, see the [Puppet Strings documentation][2] and [style guide][3].

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the
root of your module directory and list out each of your module's classes,
defined types, facts, functions, Puppet tasks, task plans, and resource types
and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

* The data type, if applicable.
* A description of what the element does.
* Valid values, if the data type doesn't make it obvious.
* Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other
warnings.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
