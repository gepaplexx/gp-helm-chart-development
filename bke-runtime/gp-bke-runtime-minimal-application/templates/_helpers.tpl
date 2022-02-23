{{/*
Expand the name of the chart.
*/}}
{{- define "gp-bke-runtime-minimal-application.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gp-bke-runtime-minimal-application.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gp-bke-runtime-minimal-application.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "gp-bke-runtime-minimal-application.labels" -}}
helm.sh/chart: {{ include "gp-bke-runtime-minimal-application.chart" . }}
{{ include "gp-bke-runtime-minimal-application.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-bke-runtime-minimal-application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-bke-runtime-minimal-application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "gp-bke-runtime-minimal-application.route.name" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "rt-%s" .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "rt-%s-%s" .Release.Name .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "rt-%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gp-bke-runtime-minimal-application.service.name" -}}
{{- if .Values.fullnameOverride -}}
{{- "svc-" .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- "svc-" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "svc-%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gp-bke-runtime-minimal-application.route.hostname" -}}
{{- if .Values.route.basename -}}
{{- if .Values.route.hostname -}}
{{- printf "%s.%s.%s" .Values.route.hostname .Release.Namespace .Values.route.basename -}}
{{- else -}}
{{- printf "%s.%s.%s" .Release.Name .Release.Namespace .Values.route.basename -}}
{{- end -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}
