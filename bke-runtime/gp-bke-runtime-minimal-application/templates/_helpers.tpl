{{/*
Create names of the appliacation
*/}}
{{- define "gp-bke-runtime-minimal-application.logical.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gp-bke-runtime-minimal-application.technical.name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gp-bke-runtime-minimal-application.service.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gp-bke-runtime-minimal-application.route.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 54 | trimSuffix "-" -}}
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
app.kubernetes.io/name: {{ include "gp-bke-runtime-minimal-application.technical.name" . }}
app.kubernetes.io/instance: {{ include "gp-bke-runtime-minimal-application.logical.name" . }}
{{- end }}

