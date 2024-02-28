# Migration

## Hiera Changes

```yaml
# Add new user data folder to data/users then add the following entry to hiera.yaml
# ---------------------------------------------------------------------------------
# Data for users
- name: "User Data"
  glob: "users/*.yaml"

# Remove old Operating System Specific Data section
# ---------------------------------------------------------------------------------
- name: "Operating System Specific Data"
  path: "os/%{facts.os.name}.yaml"

# Replace with Operating System and Version specific Data
# ---------------------------------------------------------------------------------
# Data specific to os and version such as package names and versions
- name: "Operating System and Version Specific Data"
  path: "os/%{facts.os.name}_%{facts.os.release.major}.yaml"
```