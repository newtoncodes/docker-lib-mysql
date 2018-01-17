#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
v="$1"

if [ "$v" = "" ] || [ "$v" = "5.7" ]; then
    cd ${dir}/../5.7 && docker build -t newtoncodes/mysql .
    cd ${dir}/../5.7 && docker build -t newtoncodes/mysql:5.7 .
else
    cd ${dir}/../${v} && docker build -t newtoncodes/mysql:${v} .
fi
