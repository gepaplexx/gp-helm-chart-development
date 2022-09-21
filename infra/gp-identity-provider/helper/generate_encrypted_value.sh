#!/bin/bash

filename="encryptMe.yml"

if [ ! -e ${filename} ];
then
  echo "ERROR: Es gibt keine Datei ${filename}"
  exit 1
fi

echo -e "The encrypted Value: \n"
oc create secret generic encryptedValue --from-file=encryptedValue.yaml=${filename} --dry-run=client -o yaml -n openshift-config | kubeseal -o yaml --cert <(oc -n gp-infrastructure get secret sealed-secret-keys -o jsonpath="{.data.tls\.crt}" | base64 -d) | grep encryptedValue.yaml | tr -s " " | cut -d " " -f3
echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\n"
