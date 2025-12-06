**1 field**
- SSH Username

**Special Vars requirement**
- None

**Input configuration**
```yaml
fields:
  - id: custom_private_key
    type: string
    label: Private Key (PEM)
    secret: true
    multiline: true
required:
  - custom_private_key

```

**Injector configuration**
```yaml
file:
  template.private_key_file: '{{ custom_private_key }}'
extra_vars:
  ansible_ssh_common_args: '-o IdentitiesOnly=yes'
  ansible_ssh_private_key_file: '{{ tower.filename.private_key_file }}'

```

[^1]: 
