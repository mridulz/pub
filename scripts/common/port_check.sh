#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# Description:      Interactive TCP port connectivity checker
# Author:           Mridul Ranjan
# Version:          4.0
# Updated:          2026-07-23
# Compatibility:    Linux and macOS (including macOS Bash 3.2)
#
# Requirements:
#   - bash
#   - nc (netcat)
#
# Target-file format for option 2:
#   hostname_or_ip [fallback_ip]
#
# Examples:
#   server1.example.com
#   server2.example.com 192.0.2.20
#   192.0.2.30
#
# Blank lines and lines beginning with # are ignored.
# ---------------------------------------------------------------------------

TARGET_FW_DEFAULT=25
PORT_FW=6
RESULT_FW=25
CONNECT_TIMEOUT=3

line() {
    local char="${1:--}"
    local len="${2:-}"

    if [[ -z "$len" ]]; then
        if command -v tput >/dev/null 2>&1; then
            len="$(tput cols 2>/dev/null || printf '80')"
        else
            len=80
        fi
    fi

    printf '%*s\n' "$len" '' | tr ' ' "$char"
}

trim() {
    local value="$1"

    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    printf '%s' "$value"
}

is_ip_address() {
    local target="$1"

    # Accept IPv4 and IPv6 literals. Final validity is determined by nc.
    case "$target" in
        *:*) return 0 ;;
        *[!0-9.]*|'') return 1 ;;
        *) return 0 ;;
    esac
}

dns_exists() {
    local target="$1"

    if is_ip_address "$target"; then
        return 0
    fi

    if command -v dscacheutil >/dev/null 2>&1; then
        dscacheutil -q host -a name "$target" 2>/dev/null |
            grep -Eq '^[[:space:]]*(ip_address|ipv6_address):'
        return
    fi

    if command -v getent >/dev/null 2>&1; then
        getent ahosts "$target" >/dev/null 2>&1
        return
    fi

    if command -v host >/dev/null 2>&1; then
        host "$target" >/dev/null 2>&1
        return
    fi

    if command -v nslookup >/dev/null 2>&1; then
        nslookup "$target" >/dev/null 2>&1
        return
    fi

    # nc can still perform name resolution; do not reject the target merely
    # because no standalone DNS utility is installed.
    return 0
}

valid_port() {
    local port="$1"

    case "$port" in
        ''|*[!0-9]*) return 1 ;;
    esac

    (( port >= 1 && port <= 65535 ))
}

connection_ok() {
    local target="$1"
    local port="$2"

    case "$(uname -s)" in
        Darwin)
            # macOS/BSD nc:
            #   -G = TCP connection timeout
            #   -w = network inactivity timeout
            nc -z -G "$CONNECT_TIMEOUT" -w "$CONNECT_TIMEOUT" \
                "$target" "$port" >/dev/null 2>&1
            ;;
        *)
            # Linux/OpenBSD netcat and common Linux nc implementations.
            nc -z -w "$CONNECT_TIMEOUT" \
                "$target" "$port" >/dev/null 2>&1
            ;;
    esac
}

check_target() {
    local target="$1"
    local port="$2"
    local fallback_ip="${3:-}"

    if ! valid_port "$port"; then
        printf '%s' 'FAIL (INVALID_PORT)'
        return
    fi

    if dns_exists "$target"; then
        if connection_ok "$target" "$port"; then
            printf '%s' 'PASS'
        else
            printf '%s' 'FAIL (CANNOT_CONNECT)'
        fi
        return
    fi

    if [[ -n "$fallback_ip" ]]; then
        if connection_ok "$fallback_ip" "$port"; then
            printf '%s' 'PASS'
        else
            printf '%s' 'FAIL (CANNOT_CONNECT)'
        fi
    else
        printf '%s' 'FAIL (IPADDR_UNKNOWN)'
    fi
}

longest_target_length() {
    local targets_file="$1"

    # Portable replacement for GNU "wc -L", which is unavailable on macOS.
    awk '
        {
            sub(/\r$/, "")
        }
        /^[[:space:]]*#/ || /^[[:space:]]*$/ {
            next
        }
        {
            if (length($1) > max) {
                max = length($1)
            }
        }
        END {
            print max + 0
        }
    ' "$targets_file"
}

port_check_opt_1() {
    local target
    local ports
    local port
    local port_check
    local target_len
    local target_fw
    local total_fw

    read -r -p 'Enter Target Server (FQDN/IPADDR): ' target
    target="$(trim "$target")"

    if [[ -z "$target" ]]; then
        printf 'Target cannot be empty.\n' >&2
        return 1
    fi

    read -r -p 'Enter List of Ports (separated by space): ' ports

    if [[ -z "$(trim "$ports")" ]]; then
        printf 'Port list cannot be empty.\n' >&2
        return 1
    fi

    target_len=${#target}
    target_fw=$((target_len + 4))

    if (( target_fw < TARGET_FW_DEFAULT )); then
        target_fw=$TARGET_FW_DEFAULT
    fi

    total_fw=$((target_fw + PORT_FW + RESULT_FW + 2))

    printf '\n'
    line '-' "$total_fw"
    printf "%-${target_fw}s %-${PORT_FW}s %-${RESULT_FW}s\n" \
        'TARGET' 'PORT' 'RESULT'
    line '-' "$total_fw"

    for port in $ports; do
        port_check="$(check_target "$target" "$port")"
        printf "%-${target_fw}s %-${PORT_FW}s %-${RESULT_FW}s\n" \
            "$target" "$port" "$port_check"
    done

    line '-' "$total_fw"
}

port_check_opt_2() {
    local targets
    local port
    local target
    local ipaddr
    local extra
    local port_check
    local longest_line
    local target_fw
    local total_fw
    local line_content

    read -r -p 'Enter file containing list of Target Servers: ' targets
    targets="$(trim "$targets")"

    if [[ ! -f "$targets" ]]; then
        printf 'File does not exist: %s\n' "$targets" >&2
        return 1
    fi

    read -r -p 'Enter Port: ' port
    port="$(trim "$port")"

    if ! valid_port "$port"; then
        printf 'Invalid TCP port: %s\n' "$port" >&2
        return 1
    fi

    longest_line="$(longest_target_length "$targets")"
    target_fw=$((longest_line + 4))

    if (( target_fw < TARGET_FW_DEFAULT )); then
        target_fw=$TARGET_FW_DEFAULT
    fi

    total_fw=$((target_fw + PORT_FW + RESULT_FW + 2))

    printf '\n'
    line '-' "$total_fw"
    printf "%-${target_fw}s %-${PORT_FW}s %-${RESULT_FW}s\n" \
        'TARGET' 'PORT' 'RESULT'
    line '-' "$total_fw"

    while IFS= read -r line_content || [[ -n "$line_content" ]]; do
        # Remove a Windows CR if the file uses CRLF line endings.
        line_content="${line_content%$'\r'}"
        line_content="$(trim "$line_content")"

        [[ -z "$line_content" ]] && continue
        [[ "$line_content" == \#* ]] && continue

        target=''
        ipaddr=''
        extra=''

        read -r target ipaddr extra <<< "$line_content"

        if [[ -n "$extra" ]]; then
            printf "%-${target_fw}s %-${PORT_FW}s %-${RESULT_FW}s\n" \
                "$target" "$port" 'FAIL (INVALID_LINE)'
            continue
        fi

        port_check="$(check_target "$target" "$port" "$ipaddr")"

        printf "%-${target_fw}s %-${PORT_FW}s %-${RESULT_FW}s\n" \
            "$target" "$port" "$port_check"
    done < "$targets"

    line '-' "$total_fw"
}

prechecks() {
    if (( EUID == 0 )); then
        printf 'Must not be run as root.\n' >&2
        exit 1
    fi

    if ! command -v nc >/dev/null 2>&1; then
        printf 'nc/netcat was not found in PATH.\n' >&2
        exit 1
    fi
}

main() {
    local choice

    printf '\n'
    printf 'Choose an option...\n'
    printf '1) Check multiple ports on a single target\n'
    printf '2) Check a single port on multiple targets\n'
    read -r -p 'Enter choice: ' choice
    printf '\n'

    case "$choice" in
        1) port_check_opt_1 ;;
        2) port_check_opt_2 ;;
        *)
            printf 'Invalid choice: %s\n' "$choice" >&2
            exit 1
            ;;
    esac
}

prechecks
main

