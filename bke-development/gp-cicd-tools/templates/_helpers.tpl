{{/*
Expand the name of the chart.
*/}}
{{- define "gp-cicd-tools.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gp-cicd-tools.fullname" -}}
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
{{- define "gp-cicd-tools.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-cicd-tools.labels" -}}
helm.sh/chart: {{ include "gp-cicd-tools.chart" . }}
{{ include "gp-cicd-tools.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-cicd-tools.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-cicd-tools.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gp-cicd-tools.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gp-cicd-tools.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "gp-cicd-tools.argocd.servicemonitor" -}}
{{ .Release.Name }}-argocd-metrics
{{- end }}
{{- define "gp-cicd-tools.argocd.workload" -}}
{{ .Release.Name }}-argocd-applicationset-controller
{{- end }}

{{- define "gp-cicd-tools.argocd-repo-server.servicemonitor" -}}
{{ .Release.Name }}-argocd-repo-server
{{- end }}
{{- define "gp-cicd-tools.argocd-repo-server.workload" -}}
{{ .Release.Name }}-argocd-repo-server
{{- end }}

{{- define "gp-cicd-tools.argocd-server.servicemonitor" -}}
{{ .Release.Name }}-argocd-server-metrics
{{- end }}
{{- define "gp-cicd-tools.argocd-server.workload" -}}
{{ .Release.Name }}-argocd-server
{{- end }}

