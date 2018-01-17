#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

cd ${dir}/../5.7 && docker build -t newtoncodes/mysql .
cd ${dir}/../5.7 && docker build -t newtoncodes/mysql:5.7 .
