## GP-BKE-RUNTIME-MINIMAL-APPLICATION

This Helm-Chart generates a Deployment with the configured Image (Variable 'image.name'). In addition, a route and a service can be generated automatically.

# Usage

```helm repo add gp-helm-charts https://gepaplexx.github.io/gp-helm-charts/```  
```oc new-project example-dev```  
```helm install example-app gp-helm-charts/gp-bke-deploy-app -f example-app-values.yaml -n example-dev```

## Alternative Usage

### Set values on Command Line
```helm install nginx-bke-test gepaplexx/gp-bke-runtime-minimal-application -n example-dev --set image.name=bitnami/nginx --set image.tag=latest --set route.enabled=true```

### Use local (this) chart directory
```helm install nginx-bke-test . -n example-dev --set image.name=bitnami/nginx --set image.tag=latest --set route.enabled=true```

## values.yaml

```yaml
replicaCount: 1

# metadata.name: [RELEASE-NAME]-[nameOverride]
# metadata.label.app.kubernetes.io/name: [nameOverride]
nameOverride: ""

# metadata.name: [fullnameOverride]
# metadata.label.app.kubernetes.io/name: gp-bke-runtime-minimal-application
fullnameOverride: ""

image:
  # The name of the image to be used, e.g. image-registry.openshift-image-registry.svc.cluster.local:5000/example-project/example-backend
  name: 
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion
  tag: ""

ports: {}
  # - name: http
  #   containerPort: 8080
  #   protocol: TCP

podAnnotations: {}
  # annotation1: value1
  # annotation2: value2

service:
  type: ClusterIP
  port: 8080
  targetPort: 8080

route:
  # Deploy a route for this deployment?
  enabled: false
  wildcardPolicy: None
  tls:
    enabled: true
    termination: edge

livenessProbe:
  enabled: false
  path: "" # default is /

readinessProbe:
  enabled: false
  path: "" # default is /

# Define environment variables for the pod
env: {}

resources:
  limits:
    cpu: 750m
    memory: 800Mi
  requests:
    cpu: 250m
    memory: 400Mi
```

## Example values.yml

https://raw.githubusercontent.com/gepaplexx/gp-helm-chart-development/main/bke/gp-bke-runtime-minimal-application/values.yaml
