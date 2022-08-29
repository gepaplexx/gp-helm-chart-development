#!/bin/bash

filename="alertmanager.yml"

if [ ! -e ${filename} ];
then
  echo "ERROR: Es gibt keine Datei ${filename}"
  exit 1
fi

echo -e "Dein neues Sealed Secret, füge es ein in cluster-applications/gp-cluster-applications/values/values-*.yaml -> clusterMonitoring.parameters.alertmanager.config:\n"
oc create secret generic alertmanager-main --from-file=alertmanager.yaml=${filename} --dry-run=client -o yaml -n openshift-monitoring | kubeseal -o yaml --cert <(oc -n gp-infrastructure get secret sealed-secret-keys -o jsonpath="{.data.tls\.crt}" | base64 -d) | grep alertmanager.yaml | tr -s " " | cut -d " " -f3
echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\n"
