## GP-BKE-DEPLOY-APP

This Helm-Chart generates a Deployment with the configured Image (Variable 'image.name'). In addition, a route and a service can be generated automatically.

# Usage

```helm repo add gp-helm-charts https://gepaplexx.github.io/gp-helm-charts/```  
```oc new-project example-dev```  
```helm install example-app gp-helm-charts/gp-bke-deploy-app -f example-app-values.yaml -n example-dev```

## values.yaml

```yaml
replicaCount: 1

# metadata.name: [RELEASE-NAME]-[nameOverride]
# metadata.label.app.kubernetes.io/name: [nameOverride]
nameOverride: ""

# metadata.name: [fullnameOverride]
# metadata.label.app.kubernetes.io/name: gp-bke-deploy-app
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

podSecurityContext: {}
  # fsGroup: 2000

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

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
    insecureEdgeTerminationPolicy: None
    ## IMPORTANT: Do not check 'key' into git!
    key:
    caCertificate:
    certificate:
    destinationCACertificate:

livenessProbe:
  enabled: false
  path: "" # default is /

readinessProbe:
  enabled: false
  path: "" # default is /

nodeSelector: {}
tolerations: []
affinity: {}

# Define environment variables for the pod
env: {}

volumes: {}
volumeMounts: {}

resources:
  limits:
    cpu: 750m
    memory: 800Mi
  requests:
    cpu: 250m
    memory: 400Mi

# Generate a secret for this deployment
secret:
  enabled: false
  name: ""
  data: ""
```

## Example values.yml

https://raw.githubusercontent.com/gepaplexx/gp-bke/develop/example-values/mega-zep-backend-values.yaml