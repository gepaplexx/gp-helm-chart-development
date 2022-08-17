#!/bin/bash

echo -e "Your new Secret, paste it to cluster-applications/gp-cluster-applications/values/values-*.yaml ->   clusterMonitoring.parameters.alertmanager.config:\n"
oc create secret generic alertmanager-main --from-file=alertmanager.yaml=alertmanager.yml --dry-run=client -o yaml -n openshift-monitoring | kubeseal -o yaml --cert <(kubectl -n gp-infrastructure get secret sealed-secret-keys -o jsonpath="{.data.tls\.crt}" | base64 -d) | grep alertmanager.yaml | tr -s " " | cut -d " " -f3
echo ""
