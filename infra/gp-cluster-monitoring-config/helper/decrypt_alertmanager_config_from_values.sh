#!/bin/bash

valuesFileSuffix=play

if [ -n "$1" ]; then
  valuesFileSuffix=$1
fi

valuesFile="../../../../gepardec-run-cluster-configuration/cluster-applications/gp-cluster-applications/values/values-${valuesFileSuffix}.yaml"

echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\nUnd folgendes values File: ${valuesFile}"

for CERT in $(kubectl get secret -n gp-infrastructure -l sealedsecrets.bitnami.com/sealed-secrets-key -o name); do
  COMMAND=$(kubeseal --recovery-private-key <(oc -n gp-infrastructure get ${CERT} -o jsonpath="{.data.tls\.key}" | base64 -d) --recovery-unseal -f <(helm template -s templates/08-alertmanager-config-sealed-secret.yaml --set alertmanager.config=$(grep -A2 alertmanager.config ${valuesFile} | grep value | cut -d '"' -f2) ..) -o yaml | grep -o "alertmanager.yaml.*" | cut -d " " -f2 | base64 -d | tee alertmanager-from-values-${valuesFileSuffix}.yml)
  if [ "${COMMAND}" != "" ]; then
    echo "${COMMAND}"
    exit 0
  else
    echo '>>> next cert '
  fi
done

echo "Kein Zertifikat hat funktioniert :c"
