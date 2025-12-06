**2 fields**
- SSH Username
- SSH Private Key

**Special Vars requirement**
- None

**Input configuration**
```yaml
fields:
  - id: custom_username
    type: string
    label: Username
  - id: custom_private_key
    type: string
    label: Private Key (PEM)
    secret: true
    multiline: true
required:
  - custom_username
  - custom_private_key

```

**Injector configuration**

```yaml
file:
  template.private_key_file: '{{ custom_private_key }}'
extra_vars:
  ansible_user: '{{ custom_username }}'
  ansible_ssh_common_args: '-o IdentitiesOnly=yes'
  ansible_ssh_private_key_file: '{{ tower.filename.private_key_file }}'

```

