#!/bin/bash
# ------------------------------------------------------------
# Description:          Port Checks
# Author:               zlabsroot
# Version:              2.0
# Last Update:          2023-04-20
# Comments:             Requires the nc/netcat command 
# ------------------------------------------------------------

# ------------------------------------------------------------
# VARS 
# ------------------------------------------------------------
target_fw=25
port_fw=6
result_fw=25

# ------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------
function line()
{
        cols=$(tput cols)
        char=${1--}
        len=${2-$cols}

        printf "%-${len}s" "$1" | sed "s/ /${char}/g"; echo
}

function dns_exists()
{
        nslookup $1 | grep -i "server can't find" > /dev/null 2>/dev/null && return 1 || return 0
}

function is_ipaddress()
{
        echo $1 | grep -i '[a-z]' > /dev/null 2>&1 && return 1 || return 0
}

function port_check_opt_1()
{
        read -p "Enter Target Server (FQDN/IPADDR): " target
        read -p "Enter List of Ports (separated by space): " ports

        target_len=$(echo $target | wc -c)
        target_fw=$((target_len + 4))
        total_fw=$((target_fw + port_fw + result_fw))

        echo
        line "-" $total_fw
        printf "%-${target_fw}s %-${port_fw}s %-${result_fw}s\n" "TARGET" "PORT" "RESULT" 
        line "-" $total_fw 
        for port in $ports
        do
                if is_ipaddress $target; then
                        if connection_ok $target $port; then port_check="PASS"; else port_check="FAIL (CANNOT_CONNECT)"; fi
                else
                        if dns_exists $target; then
                                if connection_ok $target $port; then port_check="PASS"; else port_check="FAIL (CANNOT_CONNECT)"; fi
                        else
                                port_check="FAIL (IPADDR_UNKNOWN)"
                        fi
                fi
                printf "%-${target_fw}s %-${port_fw}s %-${result_fw}s\n" $target $port "$port_check"
        done
        line "-" $total_fw 
}

function port_check_opt_2()
{
        read -p "Enter file containing list of Target Servers: " targets
        [ ! -f $targets ] && { echo "File doesn't exist"; exit 1; }
        read -p "Enter Port: " port

        longest_line=$(wc -L $targets | awk '{print $1}')
        target_fw=$((longest_line + 4))
        total_fw=$((target_fw + port_fw + result_fw))

        echo
        line "-" $total_fw
        printf "%-${target_fw}s %-${port_fw}s %-${result_fw}s\n" "TARGET" "PORT" "RESULT"
        line "-" $total_fw
        cat $targets | grep -v ^\# | sed '/^$/d' | while read target ipaddr 
        do
                if is_ipaddress $target; then
                        if connection_ok $target $port; then port_check="PASS"; else port_check="FAIL (CANNOT_CONNECT)"; fi
                else
                        if dns_exists $target; then
                                if connection_ok $target $port; then port_check="PASS"; else port_check="FAIL (CANNOT_CONNECT)"; fi
                        else
                                if [ ! -z $ipaddr ]; then
                                        if connection_ok $ipaddr $port; then port_check="PASS"; else port_check="FAIL (CANNOT_CONNECT)"; fi
                                else
                                        port_check="FAIL (IPADDR_UNKNOWN)"
                                fi
                        fi
                fi
                printf "%-${target_fw}s %-${port_fw}s %-${result_fw}s\n" $target $port "$port_check"
        done 
        line "-" $total_fw
}

function connection_ok()
{
        nc -vz -w3 $1 $2 >/dev/null 2>&1 && return 0 || return 1
}

function prechecks()
{
        [ $(id -u) == 0 ] && { echo "Must not be run by root"; exit 1; }

        which nc > /dev/null 2>&1 || { echo "nc/netcat not found"; exit 1; }
}

function main()
{
        echo
        echo "Choose an option..."
        echo "1) Check multiple ports on a single target"
        echo "2) Check a single port on multiple targets"
        read -p "Enter choice: " CHOICE
        echo

        case $CHOICE in
                1) port_check_opt_1 ;;
                2) port_check_opt_2 ;;
                *) echo "Invalid Choice"; exit 1;; 
        esac
}

# ------------------------------------------------------------
# MAIN 
# ------------------------------------------------------------
prechecks
main

# ------------------------------------------------------------
# EOF
# ------------------------------------------------------------

