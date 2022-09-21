#!/bin/bash

filename="encryptMe.yml"
secretname="ldap-secret"
namespace="openshift-config"

if [ ! -e ${filename} ];
then
  echo "ERROR: Es gibt keine Datei ${filename}"
  exit 1
fi

echo -e "The encrypted Value: \n"
oc create secret generic ${secretname} --from-file=value=${filename} --dry-run=client -o yaml -n ${namespace} | kubeseal -o yaml --cert <(oc -n gp-infrastructure get secret sealed-secret-keys -o jsonpath="{.data.tls\.crt}" | base64 -d)
echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\n"
