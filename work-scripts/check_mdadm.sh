#!/bin/bash

email="test@mail.ru"

cat /proc/mdstat | grep active > /dev/null
if [ $? -ne 0 ]; then
	    mail -s "RAID failure at `hostname`" "$email" << EOF

	    ===================================================

	    `cat /proc/mdstat`

	    ===================================================
	    EOF
    fi
