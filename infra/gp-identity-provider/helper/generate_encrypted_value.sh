#!/bin/bash

filename="encryptMe.yaml"
secretname="ldap-secret"
namespace="openshift-config"

if [ ! -e ${filename} ];
then
  echo "ERROR: Es gibt keine Datei ${filename}"
  exit 1
fi

echo -e "The encrypted Value: \n"
CURRSECRET=$(kubectl -n gp-infrastructure get secret --sort-by metadata.creationTimestamp | grep sealed-secrets-key | head -n 1 | cut -d " " -f 1)
oc create secret generic ${secretname} --from-file=value=${filename} --dry-run=client -o yaml -n ${namespace} | kubeseal -o yaml --cert <(oc -n gp-infrastructure get secret "${CURRSECRET}" -o jsonpath="{.data.tls\.crt}" | base64 -d)
echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\n"
