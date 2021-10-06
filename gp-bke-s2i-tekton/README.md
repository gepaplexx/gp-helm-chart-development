# GP-BKE-S2I-Tekton

This Helm-Chart deploys a Tekton Pipeline. This Pipeline needs as Input the Git-Repo of your Application (Variable 'sourceRepo') and a Builderimage (Variable 'builderImage'). With this information, a container image is built and pushed into the specified registry (Variable imageRegistry). The final image name is composed as follows: ```[imageRegistry]/[imageRepository]/[applicationName]:[sourceRevision]```

## Usage

```helm repo add gp-helm-charts https://gepaplexx.github.io/gp-helm-charts/```

```oc new-project example-cicd```

```helm install example-s2i-build gp-helm-charts/gp-bke-s2i-tekton -f example-s2i-tekton-values.yaml -n example-cicd```

## values.yaml

```yaml
# Defines the name of the image, e.g. Imagename: [REGISTRY]/[REPOSITORY]/[applicationName]:[TAG]
applicationName: 

workspace:
  # The size of the persistent volume used for this build
  size: 1Gi

# Setup of the PipelineRun
pipelineRun:
  # Create a initial PipelineRun-Resource
  create: true
  # The Git-Repo of your application 
  sourceRepo: # eg.: https://github.com/gattma/gp-management.git
  # The Revision which should used to build an image, e.g. [REGISTRY]/[REPOSITORY]/[APPLICATIONNAME]:[sourceRevision]
  sourceRevision: # eg.: 957ff8da4ce01a0908e26d67c806392b1e484c37
  # Use contextdir if your application is not in the root directory of the specified repository
  contextDir: # eg.: frontend/management-ui
  # Into this registry the final image is pushed, e.g. [imageRegistry]/[REPOSITORY]/[APPLICATIONNAME]:[TAG]
  imageRegistry: # image-registry.openshift-image-registry.svc.cluster.local:5000
  # The Repositry into wich the final image gets pushed, e.g. [REGISTRY]/[imageRepository]/[APPLICATIONNAME]:[TAG]
  imageRepository: # default = Release.Namespace
  # The s2i builder image wich should be used to build the image
  builderImage: # image-registry.openshift-image-registry.svc:5000/mega-test-gattma/s2i-angular@sha256:210f4f235770b559f63fdcae02425ac95a55ca4660cb0c19dbdf1aded6c48495
```
## Example values.yaml

https://raw.githubusercontent.com/gepaplexx/gp-bke/develop/example-values/mega-zep-frontend-build-values.yaml 