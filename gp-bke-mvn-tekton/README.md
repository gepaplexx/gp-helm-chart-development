# GP-BKE-MVN-TEKTON

This Helm-Chart deploys a Tekton Pipeline. This Pipeline needs as Input the Git-Repo of your Maven-Application (Variable 'sourceRepo') and the path to a Dockerfile (Variable 'dockerfile'). With this information, a container image is built and pushed into the specified registry (Variable imageRegistry). The final image name is composed as follows: ```[imageRegistry]/[imageRepository]/[applicationName]:[sourceRevision]```

## Usage

```helm repo add gp-helm-charts https://gepaplexx.github.io/gp-helm-charts/```  
```oc new-project example-cicd```  
```helm install -f example-build-values.yaml example-mvn-build gp-helm-charts/gp-bke-mvn-tekton -n example-cicd```

## values.yaml

```yaml
# Defines the name of the image, e.g. Imagename: [REGISTRY]/[REPOSITORY]/[applicationName]:[TAG]
applicationName: ""

pipeline:
  mvn:
    # This image which is used to build the maven project
    image: maven:3.6.3-adoptopenjdk-11

workspace:
  # The size of the persistent volume used for this build
  size: 1Gi

# Setup of the PipelineRun
pipelineRun:
  # Create a initial PipelineRun-Resource
  create: true
  # The Git-Repo of your application 
  sourceRepo: "" # e.g. https://github.com/gepaplexx/gp-test-services.git
  # The Revision which should used to build an image, e.g. [REGISTRY]/[REPOSITORY]/[APPLICATIONNAME]:[sourceRevision]
  sourceRevision: "" # e.g. 0d41126cfd0af6471e8d09e7af92aecd0a3a84a6
  shortSourceRevision: "" # e.g. 0d41126
  # Use contextdir if your application is not in the root directory of the specified repository
  contextdir: "" # e.g. serviceA
  # The Dockerfile wich should be used to build the image
  dockerfile: # default = ./src/main/docker/Dockerfile.jvm
  # Into this registry the final image is pushed, e.g. [imageRegistry]/[REPOSITORY]/[APPLICATIONNAME]:[TAG]
  imageRegistry: image-registry.openshift-image-registry.svc.cluster.local:5000
  # The Repositry into wich the final image gets pushed, e.g. [REGISTRY]/[imageRepository]/[APPLICATIONNAME]:[TAG]
  imageRepository: # default = Release.Namespace
```

## Example values.yml

https://raw.githubusercontent.com/gepaplexx/gp-bke/develop/example-values/mega-zep-backend-build-values.yaml 