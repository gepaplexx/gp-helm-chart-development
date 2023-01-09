#!/bin/bash

valuesFileSuffix=play

if [ -n "$1" ]; then
  valuesFileSuffix=$1
fi

valuesFile="../../../../gepardec-run-cluster-configuration/cluster-applications/gp-cluster-applications/values/values-${valuesFileSuffix}.yaml"

echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\nUnd folgendes values File: ${valuesFile}"

for CERT in $(kubectl get secret -n gp-infrastructure -l sealedsecrets.bitnami.com/sealed-secrets-key -o name); do
  COMMAND=$(kubeseal --recovery-private-key <(oc -n gp-infrastructure get ${CERT} -o jsonpath="{.data.tls\.key}" | base64 -d) --recovery-unseal -f <(helm template -s templates/loki-hub-secret-sealed-secret.yaml --set loki_hub_secret.password=$(grep -A2 loki_hub_secret.password ${valuesFile} | grep value | cut -d '"' -f2) --set loki_hub_secret.username=$(grep -A2 loki_hub_secret.username ${valuesFile} | grep value | cut -d '"' -f2) --set loki_hub_secret.tlscrt=$(grep -A2 loki_hub_secret.tlscrt ${valuesFile} | grep value | cut -d '"' -f2) --set loki_hub_secret.tlskey=$(grep -A2 loki_hub_secret.tlskey ${valuesFile} | grep value | cut -d '"' -f2) ..) -o yaml | tee loki-hub-secret-from-values-${valuesFileSuffix}.yaml)
  if [ "${COMMAND}" != "" ]; then
    echo "${COMMAND}"
    exit 0
  else
    echo '>>> next cert '
  fi
done

echo "Kein Zertifikat hat funktioniert :c"