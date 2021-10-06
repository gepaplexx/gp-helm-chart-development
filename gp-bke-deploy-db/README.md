# GP-BKE-DEPLOY-DB

This Helm-Chart deploys an Instance of the selected Database (Variable create = true). At the moment only Postgres is supported.

## Usage

```helm repo add gp-helm-charts https://gepaplexx.github.io/gp-helm-charts/```

```oc new-project example-dev```

```helm install example-db gp-helm-charts/gp-bke-deploy-db -f example-db-values.yaml -n example-dev```

## values.yaml

```yaml
# metadata.name: [RELEASE-NAME]-[nameOverride]
# metadata.label.app.kubernetes.io/name: [nameOverride]
nameOverride: "mega-zep-db"

# metadata.name: [fullnameOverride]
# metadata.label.app.kubernetes.io/name: gp-bke-deploy-app
fullnameOverride: "mega-zep-db"

postgres:
  # deploy a new postgres database, at the moment only postgres database are supported
  deploy: true
  image: registry.developers.crunchydata.com/crunchydata/crunchy-postgres-ha:centos8-13.4-0
  postgresVersion: 13
  storage: 1Gi
  resources:
    requests:
      cpu: 200m
      memory: 200Mi
    limits:
      cpu: 750m
      memory: 800Mi
  backup:
    image: registry.developers.crunchydata.com/crunchydata/crunchy-pgbackrest:centos8-2.33-2
    storage: 1Gi
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
      limits:
        cpu: 500m
        memory: 500Mi
  # Create a user at startup
  user: ""
  # Create a database at startup, only considered in combination with a user
  databases: {}
  # - "dummy"
```

## Example values.yml

https://raw.githubusercontent.com/gepaplexx/gp-bke/develop/example-values/mega-zep-db-values.yaml