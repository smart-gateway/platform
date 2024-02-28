# User Management

Users can be declared anywhere in the hierarchy but should generally follow these guidelines.

- Local users that should be platform wide should be defined in `data/users`
- Domain users that should be platform wide should be defined in `data/users`
- Local users that should be defined on specific systems should be defined in `data/nodes/<node_name>.yaml`

## YAML Schema

```yaml
users:
    ensure: string                                  # present | absent - ensure account is present or absent
    type: string                                    # local | domain - account type
    comment: string                                 # comment for account
    shell: string                                   # sh | bash | zsh - default shell for the user
    groups:                                         # List of the users groups. local or domain specific
        - string
    password: string                                # hashed password
    keys:
        key_name_1:                                 # Name of key must be unique
            key_type: string                        # rsa | ed25519
            key_value: string                       # base64 encoded public key
    import-keys:                                    # list of github or launchpad accounts to import keys from
        - string                                    # ex: gh:bgrewell lp:username
    files:
        filename_1:                                 # name of file relative to users home directory
            source: string                          # url - source of the file
            create_only: bool                       # true | false - true=create file only, false=update when modified
            mode: string                            # '0755' etc - file permissions string
    shell-options:
        bash: {}                                    # Currently no bash options
        zsh:
            oh-my-zsh:                              
                ensure: string                      # present | absent - install/uninstall oh-my-zsh for user
                theme: string                       # oh-my-zsh theme to use
                plugins:
                    git: {}                         # empty value for hash means it's a oh-my-zsh local plugin
                    zsh-autosuggestions:
                        source: string              # url for the plugin git repository
            powerlevel10k:
                ensure: string                      # present | absent - install/uninstall powerlevel10k for user
                p10k_config: string                 # url to .p10k.zsh file
                with_oh_my_zsh: bool                # true if oh-my-zsh is also being installed
```