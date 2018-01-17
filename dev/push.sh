#!/usr/bin/env bash

v="$1"

if [ "$v" = "" ] || [ "$v" = "5.7" ]; then
    docker push newtoncodes/mysql
    docker push newtoncodes/mysql:5.7
else
    docker push newtoncodes/mysql:${v}
fi
