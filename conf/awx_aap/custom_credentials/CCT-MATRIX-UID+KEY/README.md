**2 fields**
- SSH Username
- SSH Private Key

**Special Vars requirement**
```yaml
ansible_user: "{{ matrix_user }}"
ansible_ssh_private_key_file: "{{ matrix_priv_keyfile }}"
```

**Input configuration**

```yaml
fields:
  - id: matrix_username
    type: string
    label: Matrix User
  - id: matrix_priv_key
    type: string
    label: Matrix Private Key
    secret: true
    multiline: true
required:
  - matrix_username
  - matrix_private_key

```

**Injector configuration**

```yaml
file:
  template.matrix_priv_keyfile: '{{ matrix_priv_key }}'
extra_vars:
  matrix_user: '{{ matrix_username }}'
  matrix_priv_keyfile: '{{ tower.filename.matrix_priv_keyfile }}'

```