#!/bin/bash

filename="loki-hub-secret.yaml"

if [ ! -e ${filename} ];
then
  echo "ERROR: Es gibt keine Datei ${filename}"
  exit 1
fi

echo -e "Dein neues Sealed Secret, füge es ein in cluster-applications/gp-cluster-applications/values/values-*.yaml -> clusterLogging.parameters.loki-hub-secret.{einzugebender_paramter}:\n"
cat ${filename} | kubeseal \
    --controller-namespace gp-infrastructure \
    --controller-name sealed-secrets-operator \
    --format yaml \
    > sealed-${filename}.yaml
echo -e "\nACHTUNG: Du verwendest gerade: $(oc whoami --show-server=true)\n"
