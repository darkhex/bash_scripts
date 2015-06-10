#!/bin/bash
xl top | tr '\r' '\n' | sed 's/[0-9][;][0-9][0-9][a-Z]/ /g' | col -bx | sed 1,4d | awk '{print $2,$5,$6}'

