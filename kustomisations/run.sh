# Nur fuer lokale Tests. Bei Bedarf: ./run.sh | kubectl apply -f -
kustomize build bkes/bke-app-example --enable-exec --enable-alpha-plugins
