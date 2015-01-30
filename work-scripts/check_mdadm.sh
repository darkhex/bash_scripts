#!/bin/bash
# Script to check software raid status and email if there is a problem
# Written by Garth van Sittert

# Some variables to specify
email="me@me.com"



##########################################################

# Display RAID status
cat /proc/mdstat

# Check for [U_] or [_U]
if ! egrep "\[.*_.*\]" /proc/mdstat  > /dev/null
then exit
fi

# email a report
mail -s "RAID failure at `hostname`" "$email" << EOF

===================================================

`cat /proc/mdstat`

===================================================
EOF
