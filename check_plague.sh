#!/bin/bash

echo "Plague PAM-backdoor’ni aniqlash..."

# IoC — hash'lar orqali aniqlash
ioc_hashes=(
  "3fa1a707be16fd1d64d063215f169a063a6478f41e3e7bfa7d1f5569e7723ce5"
  "c3600c376c5c3573d7a6460cd8cb871e24a4ed3f63e503296c02b447fd87711d"
  "d2f82e8c9fc44a9f48e0bde7603c69ea2a4006c8f6a168d8edc5c7d1578d39e3"
)

# Vaqtinchalik fayllar
tmp_hashes=$(mktemp)
tmp_strings=$(mktemp)

# 1. pam_*.so fayllarni topish va hash'larni solishtirish
find /lib* /usr/lib* -name "pam_*.so" -exec sha256sum {} \; > "$tmp_hashes"

found_ioc_hash=""
for h in "${ioc_hashes[@]}"; do
  if grep -q "$h" "$tmp_hashes"; then
    found_ioc_hash=$h
    break
  fi
done

# 2. /etc/pam.d/sshd faylida noodatiy/qo'lbola modullar borligini tekshirish
pam_line=$(grep -E 'pam_.*\.so' /etc/pam.d/sshd | grep -vE 'pam_(unix|env|nologin|motd|limits|permit).so')

# 3. PAM modullar ichida shubhali qatorlarni izlash
strings /lib*/security/pam_*.so 2>/dev/null | grep -Ei 'unsetenv|HISTFILE|gcc' > "$tmp_strings"

echo

# 4. Natijani chiqarish
if [[ -n "$found_ioc_hash" ]]; then
  echo "Xavf: zararli PAM modul topildi (IoC: $found_ioc_hash)"
elif [[ -n "$pam_line" ]]; then
  echo "Diqqat: /etc/pam.d/sshd da noodatiy modul:"
  echo "$pam_line"
elif [[ -s "$tmp_strings" ]]; then
  echo "Shubhali qatorlar topildi PAM modullarda:"
  cat "$tmp_strings"
else
  echo "Plague: aniqlanmadi"
fi

# Tozalash
rm -f "$tmp_hashes" "$tmp_strings"
