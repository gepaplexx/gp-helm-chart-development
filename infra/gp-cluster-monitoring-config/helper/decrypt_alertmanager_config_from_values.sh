cluster=play

if [ -n "$1" ];
then
  cluster=$1
fi

kubeseal --recovery-private-key <(kubectl -n gp-infrastructure get secret sealed-secret-keys -o jsonpath="{.data.tls\.key}" | base64 -d) --recovery-unseal -f <(helm template -s templates/08-alertmanager-config-sealed-secret.yaml --set alertmanager.config=$(grep -A2 alertmanager.config  ../../../../gepardec-run-cluster-configuration/cluster-applications/gp-cluster-applications/values/values-${cluster}.yaml | grep value | cut -d '"' -f2) ..) -o yaml | grep -o "alertmanager.yaml.*" | cut -d " " -f2 | base64 -d
