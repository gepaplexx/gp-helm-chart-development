{{/*
Expand the name of the chart.
*/}}
{{- define "gp-kasten-backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gp-kasten-backup.fullname" -}}
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
{{- define "gp-kasten-backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gp-kasten-backup.labels" -}}
helm.sh/chart: {{ include "gp-kasten-backup.chart" . }}
{{ include "gp-kasten-backup.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gp-kasten-backup.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gp-kasten-backup.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gp-kasten-backup.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gp-kasten-backup.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "gp-kasten-backup.openshift.auth.clientSecret" -}}
{{- range $index,$secret := (lookup "v1" "ServiceAccount" .Release.Namespace .Values.kasten.auth.serviceAccountName).secrets -}}
{{- if contains "token" $secret.name -}}
{{- $token := (lookup "v1" "Secret" $.Release.Namespace $secret.name ).data.token | b64dec }}
{{- $token  }}
{{- end -}}
{{- end -}}
{{- end -}}