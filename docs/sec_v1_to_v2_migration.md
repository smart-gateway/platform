# Migration

## Hiera Changes

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