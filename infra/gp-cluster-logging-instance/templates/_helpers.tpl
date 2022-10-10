{{/*
Add nodeselector definition. Be aware about the indent.
*/}}
{{- define "infranodes.enabled" -}}
{{- if .Values.infranodes.enabled -}}
nodeSelector:
  node-role.kubernetes.io/infra: ""
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "gp-clusterlogging-instance.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gp-clusterlogging-instance.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gp-clusterlogging-instance.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-clusterlogging-instance.labels" -}}
helm.sh/chart: {{ include "gp-clusterlogging-instance.chart" . }}
{{ include "gp-clusterlogging-instance.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-clusterlogging-instance.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-clusterlogging-instance.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gp-clusterlogging-instance.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gp-clusterlogging-instance.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "gp-clusterlogging-instance.session_secret" -}}
{{ randAlphaNum 32 }}
{{- end }}