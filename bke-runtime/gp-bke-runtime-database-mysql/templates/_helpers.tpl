{{/*
Expand the name of the chart.
*/}}
{{- define "gp-bke-runtime-database-mysql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gp-bke-runtime-database-mysql.database" -}}
{{- .Values.db.auth.database }}
{{- end }}

{{- define "gp-bke-runtime-database-mysql.jdbcurl" -}}
{{- printf "jdbc:mysql://%s:%.0f/%s" ( include "mysql.primary.fullname" .Subcharts.db ) .Values.db.primary.service.port (include "gp-bke-runtime-database-mysql.database" .) }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gp-bke-runtime-database-mysql.fullname" -}}
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
{{- define "gp-bke-runtime-database-mysql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-bke-runtime-database-mysql.labels" -}}
helm.sh/chart: {{ include "gp-bke-runtime-database-mysql.chart" . }}
{{ include "gp-bke-runtime-database-mysql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-bke-runtime-database-mysql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-bke-runtime-database-mysql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gp-bke-runtime-database-mysql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gp-bke-runtime-database-mysql.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
