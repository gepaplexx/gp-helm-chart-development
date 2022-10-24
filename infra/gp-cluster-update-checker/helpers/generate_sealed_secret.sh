#!/bin/bash

filename="slack-channel.yml"

if [ ! -e ${filename} ];
then
  echo "ERROR: Es gibt keine Datei ${filename}"
  exit 1
fi

echo -e "Dein neues Sealed Secret, füge es ein in cluster-applications/gp-cluster-applications/values/values-*.yaml -> clusterUpdater.parameters.slack.channel.value:\n"
oc create secret generic cluster-update-secret --from-file=slackTargetChannel=${filename} --dry-run=client -o yaml -n gp-infrastructure | kubeseal -o yaml --cert <(kubeseal --fetch-cert --controller-name sealed-secrets-operator --controller-namespace gp-infrastructure) | grep slackTargetChannel | tr -s " " | cut -d " " -f3
echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\n"
