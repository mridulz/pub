**2 fields**
- Username
- Password

**Special Vars requirement**
- None

**Input configuration**
```yaml
fields:
  - id: custom_username
    type: string
    label: Username
  - id: custom_password
    type: string
    label: Password
    secret: true
required:
  - custom_username
  - custom_password

```

**Injector configuration**

```yaml
extra_vars:
  ansible_user: '{{ custom_username }}'
  ansible_password: '{{ custom_password }}'

```