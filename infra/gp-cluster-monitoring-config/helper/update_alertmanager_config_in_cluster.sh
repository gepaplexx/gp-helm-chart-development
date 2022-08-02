echo "Es wird ein Update auf das SealedSecret gemacht."
echo "Das SealedSecret wird dann widerum zum secret alertmanager-main."
echo "Wenn ArgoCD Auto Sync ein ist, wird das überschrieben."

SEALED_SECRET=$(oc create secret generic alertmanager-main --from-file=alertmanager.yaml=alertmanager.yml --dry-run=client -o yaml -n openshift-monitoring | kubeseal -o json --cert <(kubectl -n gp-infrastructure get secret sealed-secret-keys -o jsonpath="{.data.tls\.crt}" | base64 -d))
echo $SEALED_SECRET | oc -n openshift-monitoring apply -f -
