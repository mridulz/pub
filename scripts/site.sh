#!/bin/bash
# --------------------------------------------------------------------------------------------------
# Author:           Mridul Ranjan
# Version:          2.0
# Last Updated:     2026-07-20
# --------------------------------------------------------------------------------------------------

# Variables
site_port_default=443

# User Input
[[ -n "$1" ]] && site_url="$1" || read -r "site_url?Enter URL: "

# Vars Evaluate
site_authority="${site_url#*://}"
site_authority="${site_authority%%[/?#]*}"
site_domain="${site_authority%%:*}"
site_port=$(printf '%s\n' "$site_url" | sed -nE 's~^[a-zA-Z]+://~~; s~[/?#].*$~~; s~.*:([0-9]+)$~\1~p')
site_port=${site_port:-$site_port_default}

# SAN(s)
site_sans=$(\
openssl s_client \
  -connect "${site_domain}:${site_port}" \
  -servername "${site_domain}" \
  </dev/null 2>/dev/null \
  | openssl x509 -text -noout \
  | awk '
      /X509v3 Subject Alternative Name/ {
          getline
          gsub(/DNS:/, "")
          gsub(/IP Address:/, "")
          gsub(/, /, "\n")
          print
      }
    ' \
  | awk '{print $1}' \
  | sort \
  | tr '\n' ',' \
  | sed 's/,$//'
)

# Cert Expiry
site_cert_expiry=$(\
openssl s_client \
  -connect "${site_domain}:${site_port}" \
  -servername "${site_domain}" \
  </dev/null 2>/dev/null \
  | openssl x509 -noout -dates \
  | while IFS== read -r key cert_date; do
      TZ=America/Toronto date -d "$cert_date" '+%b %d %H:%M:%S %Y %Z'
    done \
  | awk 'NR==1 { start=$0 } NR==2 { print "[" start "] to [" $0 "]" }'
)

# Cert Issuer
site_cert_issuer=$(openssl s_client -connect "$site_domain:$site_port" -servername "$site_domain" </dev/null 2>/dev/null | openssl x509 -noout -issuer)

printf "%-15s %s\n" "URL" "$site_url"
#printf "%-15s %s\n" "Domain" "$site_domain"
#printf "%-15s %s\n" "Port" "$site_port"
printf "%-15s %s\n" "Cert Issuer" "$site_cert_issuer"
printf "%-15s %s\n" "Cert Expiry" "$site_cert_expiry"
printf "%-15s %s\n" "SAN(s)" "$site_sans"

# EOF

