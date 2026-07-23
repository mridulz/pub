#!/bin/bash
# --------------------------------------------------------------------------------------------------
# Author:           Mridul Ranjan
# Version:          2.1
# Last Updated:     2026-07-20
# --------------------------------------------------------------------------------------------------

# Defaults
site_port_default=443
site_timezone="America/Toronto"

# User input
if [[ -n "${1:-}" ]]; then
    site_url="$1"
else
    read -r -p "Enter URL: " site_url
fi

# Remove scheme, path, query, and fragment
site_authority="${site_url#*://}"
site_authority="${site_authority%%[/?#]*}"

# Extract domain
site_domain="${site_authority%%:*}"

# Extract port or use default
if [[ "$site_authority" == *:* ]]; then
    site_port="${site_authority##*:}"
else
    site_port="$site_port_default"
fi

# Validate port
if [[ -z "$site_port" || "$site_port" == *[!0-9]* ]]; then
    printf 'Invalid port: %s\n' "$site_port" >&2
    exit 1
fi

# Convert an OpenSSL GMT date to Eastern time
format_cert_date() {
    cert_date="$1"

    case "$(uname -s)" in
        Darwin)
            # macOS/BSD date
            TZ="$site_timezone" date -j \
                -f '%b %e %H:%M:%S %Y %Z' \
                "$cert_date" \
                '+%b %d %H:%M:%S %Y %Z'
            ;;
        *)
            # GNU/Linux date
            TZ="$site_timezone" date \
                -d "$cert_date" \
                '+%b %d %H:%M:%S %Y %Z'
            ;;
    esac
}

# Retrieve the certificate once
site_certificate=$(
    openssl s_client \
        -connect "${site_domain}:${site_port}" \
        -servername "$site_domain" \
        </dev/null 2>/dev/null \
    | openssl x509 -outform PEM 2>/dev/null
)

if [[ -z "$site_certificate" ]]; then
    printf 'Unable to retrieve certificate from %s:%s\n' \
        "$site_domain" "$site_port" >&2
    exit 1
fi

# SAN(s)
site_sans=$(
    printf '%s\n' "$site_certificate" \
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
    | awk '{$1=$1; print}' \
    | sort \
    | tr '\n' ',' \
    | sed 's/,$//'
)

# Certificate dates
site_cert_dates=$(
    printf '%s\n' "$site_certificate" \
    | openssl x509 -noout -dates
)

site_cert_not_before=$(
    printf '%s\n' "$site_cert_dates" \
    | sed -n 's/^notBefore=//p'
)

site_cert_not_after=$(
    printf '%s\n' "$site_cert_dates" \
    | sed -n 's/^notAfter=//p'
)

site_cert_not_before=$(
    format_cert_date "$site_cert_not_before"
)

site_cert_not_after=$(
    format_cert_date "$site_cert_not_after"
)

# Certificate issuer
site_cert_issuer=$(
    printf '%s\n' "$site_certificate" \
    | openssl x509 -noout -issuer \
    | sed 's/^issuer= *//'
)

# Output
printf '%-16s %s\n' "URL"             "$site_url"
printf '%-16s %s\n' "Domain"          "$site_domain"
printf '%-16s %s\n' "Port"            "$site_port"
printf '%-16s %s\n' "Cert Issuer"     "$site_cert_issuer"
printf '%-16s %s\n' "Cert Valid From" "$site_cert_not_before"
printf '%-16s %s\n' "Cert Valid To"   "$site_cert_not_after"
printf '%-16s %s\n' "SAN(s)"          "$site_sans"

# EOF
