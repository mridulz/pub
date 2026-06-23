```
jarvis@ams.z
$ ll /z/tarballs/
total 17G
-rw-r--r-- 1 1024 users 2.1G Jan 16  2024 ansible-automation-platform-containerized-setup-bundle-2.4-2-x86_64.tar.gz
-rw-r--r-- 1 1024 users 2.4G Nov 30  2025 ansible-automation-platform-containerized-setup-bundle-2.5-18-x86_64.tar
-rw-r--r-- 1 1024 users 3.9G Nov 30  2025 ansible-automation-platform-containerized-setup-bundle-2.6-2-x86_64.tar.gz
-rw-r--r-- 1 1024 users 2.7G May  5 15:19 ansible-automation-platform-setup-bundle-2.4-16.1-x86_64.tar.gz
-rw-r--r-- 1 1024 users 2.3G May  5 15:34 ansible-automation-platform-containerized-setup-bundle-2.5-23.1-x86_64.tar.gz
-rw-r--r-- 1 1024 users 3.5G May  5 15:36 ansible-automation-platform-setup-bundle-2.5-22.1-x86_64.tar.gz

jarvis@ams.z  ~
$ ll
total 0
drwxrwxr-x 4 jarvis jarvis 32 Nov 30  2025 2.4
drwxrwxr-x 4 jarvis jarvis 32 Nov 30  2025 2.5
drwxrwxr-x 3 jarvis jarvis 19 May 24 16:33 install

jarvis@ams.z  ~
$ tree 2.4/ 2.5/
2.4/
├── rhel8
│   └── ansible-automation-platform-setup-bundle-2.4-16.1-x86_64.tar.gz -> /z/tarballs/ansible-automation-platform-setup-bundle-2.4-16.1-x86_64.tar.gz
└── rhel9
    ├── ansible-automation-platform-containerized-setup-bundle-2.4-2-x86_64.tar.gz -> /z/tarballs/ansible-automation-platform-containerized-setup-bundle-2.4-2-x86_64.tar.gz
    └── ansible-automation-platform-setup-bundle-2.4-16.1-x86_64.tar.gz -> /z/tarballs/ansible-automation-platform-setup-bundle-2.4-16.1-x86_64.tar.gz
2.5/
├── rhel8
│   └── ansible-automation-platform-setup-bundle-2.5-22.1-x86_64.tar.gz -> /z/tarballs/ansible-automation-platform-setup-bundle-2.5-22.1-x86_64.tar.gz
└── rhel9
    ├── ansible-automation-platform-containerized-setup-bundle-2.5-23.1-x86_64.tar.gz -> /z/tarballs/ansible-automation-platform-containerized-setup-bundle-2.5-23.1-x86_64.tar.gz
    └── ansible-automation-platform-setup-bundle-2.5-22.1-x86_64.tar.gz -> /z/tarballs/ansible-automation-platform-setup-bundle-2.5-22.1-x86_64.tar.gz
```

