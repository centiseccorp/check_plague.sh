# check_plague.sh

Universal Tekshiruvchi Skript

Aniqlash Usullari:

```
grep pam_ /etc/pam.d/sshd
find /lib* /usr/lib* -name "pam_*.so" -exec sha256sum {} \;
strings /lib*/security/pam_*.so | grep -Ei "unsetenv|HISTFILE|gcc"
```

IoC (SHA256):

```
3fa1a707be16fd1d64d063215f169a063a6478f41e3e7bfa7d1f5569e7723ce5  
c3600c376c5c3573d7a6460cd8cb871e24a4ed3f63e503296c02b447fd87711d  
d2f82e8c9fc44a9f48e0bde7603c69ea2a4006c8f6a168d8edc5c7d1578d39e3
```
