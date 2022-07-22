{{/*
Expand the name of the chart.
*/}}
{{- define "gp-hashicorp-vault.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gp-hashicorp-vault.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-hashicorp-vault.labels" -}}
helm.sh/chart: {{ include "gp-hashicorp-vault.chart" . }}
{{ include "gp-hashicorp-vault.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-hashicorp-vault.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-hashicorp-vault.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}