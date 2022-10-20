#!/bin/bash

filename="alertmanager.yml"

if [ -e ${filename} ];
then
  cp ${filename} $(date +%Y-%m-%d_%H-%M-%S)_${filename}
fi

echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\n"

oc -n openshift-monitoring get secret alertmanager-main -o jsonpath="{.data.alertmanager\.yaml}" | base64 -d > ${filename}
