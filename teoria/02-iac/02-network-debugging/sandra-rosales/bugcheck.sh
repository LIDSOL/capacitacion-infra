#!/bin/bash

# Hacer ping y registrar el resultado
ping -c 3 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Ping falló en $(date) el sistema se reinició" >> /var/log/bugcheck.log
    /sbin/reboot
fi

