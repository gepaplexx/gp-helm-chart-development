{{/*
Expand the name of the chart.
*/}}
{{- define "gp-alertmanager-healthcheck.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-alertmanager-healthcheck.labels" -}}
helm.sh/chart: {{ include "gp-alertmanager-healthcheck.chart" . }}
{{ include "gp-alertmanager-healthcheck.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
name: {{ .Release.Name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gp-alertmanager-healthcheck.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-alertmanager-healthcheck.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-alertmanager-healthcheck.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "gp-alertmanager-healthcheck.annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
{{- end }}