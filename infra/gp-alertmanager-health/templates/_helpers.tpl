{{/*
Expand the name of the chart.
*/}}
{{- define "gp-alertmanager-health.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-alertmanager-health.labels" -}}
helm.sh/chart: {{ include "gp-alertmanager-health.chart" . }}
{{ include "gp-alertmanager-health.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
name: {{ .Release.Name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gp-alertmanager-health.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-alertmanager-health.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-alertmanager-health.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "gp-alertmanager-health.annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
{{- end }}