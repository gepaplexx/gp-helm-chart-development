{{/*
Expand the name of the chart.
*/}}
{{- define "gp-multena.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gp-multena-rbac-collector.name" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- print $name "-rbac-collector" | trunc 63 | trimSuffix "-" -}}
{{- end }}



{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gp-multena.fullname" -}}
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
{{- define "gp-multena.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-multena.labels" -}}
helm.sh/chart: {{ include "gp-multena.chart" . }}
{{ include "gp-multena.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-multena.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-multena.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "gp-multena-rbac-collector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-multena-rbac-collector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gp-multena.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gp-multena.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "gp-multena.secretName" -}}
{{ .Values.proxy.db.existingSecret | default (printf "%s-db-external-secret" (include "gp-multena.name" .)) }}
{{- end }}