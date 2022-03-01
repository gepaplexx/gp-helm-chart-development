{{/*
Expand the name of the chart.
*/}}
{{- define "gp-bke-runtime-database-postgresql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gp-bke-runtime-database-postgresql.fullname" -}}
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
{{- define "gp-bke-runtime-database-postgresql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-bke-runtime-database-postgresql.labels" -}}
helm.sh/chart: {{ include "gp-bke-runtime-database-postgresql.chart" . }}
{{ include "gp-bke-runtime-database-postgresql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-bke-runtime-database-postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-bke-runtime-database-postgresql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gp-bke-runtime-database-postgresql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gp-bke-runtime-database-postgresql.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "db.secretName" -}}
{{- if .Values.db.fullnameOverride }}
{{- .Values.db.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "db" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "db.database" -}}
{{- if .Values.global.postgresql.auth.database }}
    {{- .Values.global.postgresql.auth.database -}}
{{- else if .Values.db.auth.database -}}
    {{- .Values.db.auth.database -}}
{{- end -}}
{{- end -}}

{{- define "db.jdbcurl" -}}
{{- printf "jdbc:postgresql://%s:%s/%s" ( include "db.primary.fullname" . ) ( include "postgresql.service.port" . ) (include "db.database" .) }}
{{- end }}

{{- define "db.image" -}}
{{- $registryName := .Values.db.image.registry -}}
{{- $repositoryName := .Values.db.image.repository -}}
{{- $tag := .Values.db.image.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{- define "db.primary.fullname" -}}
{{- if .Values.db.fullnameOverride }}
{{- .Values.db.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "db" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Return PostgreSQL service port
*/}}
{{- define "postgresql.service.port" -}}
{{- if .Values.global.postgresql.service.ports.postgresql }}
    {{- .Values.global.postgresql.service.ports.postgresql -}}
{{- else -}}
    {{- .Values.db.primary.service.ports.postgresql -}}
{{- end -}}
{{- end -}}