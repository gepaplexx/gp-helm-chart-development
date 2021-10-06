# GP-BKE-ARGOCD-HELM

This Helm-Chart deploys an ArgoCD-Application. Therefore the URL to your Repository is needed. This repository must contain a Helm-Chart to deploy your Application. 

To make things easier, you can use the 'gp-bke-deploy-app'-Chart as dependency (Called 'Helm-Subchart-Deployment-Pattern', look at https://cloud.redhat.com/blog/continuous-delivery-with-helm-and-argo-cd).

## Usage

```helm repo add gp-helm-charts https://gepaplexx.github.io/gp-helm-charts/```  
```oc new-project example-cicd```  
```helm install example-argocd gp-helm-charts/gp-bke-argocd-helm -f example-argocd-values.yaml -n example-cicd```

## values.yaml

```yaml
argocd:
  # Indicates whether the specified instance (instanceName) already exists
  instanceAlreadyExisting: true
  # Name of an ArgoCD instance, a new one will be created if the provided one doesn't exist
  instanceName: ""
  project:
    # false = create new/override existing project, true = use existing project, fail if there is no project found
    alreadyExisting: true
    # Name of the ArgoCD Project, default-project is "default"
    name: ""
  application:
    # Name of the ArgoCD Application
    name: ""
    destination:
      # The namespace in which the application is deployed
      namespace: ""
    source:
      # Relative path of the Helm-Chart in your Repo to deploy the Application
      chartPath: "" 
      # Git Repo in which your application is located
      appRepoURL: ""
      # The branch to be used
      appRevision: "main"
      # Relative URL of the values.yaml to be used
      valuesYaml: "values.yaml" 
    syncPolicy:
      prune: true
      selfHeal: true
```

## Example values.yml

https://raw.githubusercontent.com/gepaplexx/gp-bke/develop/example-values/mega-zep-backend-argocd-values.yaml 