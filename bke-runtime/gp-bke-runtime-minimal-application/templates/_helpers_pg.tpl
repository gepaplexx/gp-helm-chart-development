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

{{- define "gp-bke-runtime-minimal-application.route.hostname" -}}
{{- if .Values.route.hostname -}}
{{ .Values.route.hostname }}
{{- else if .Values.route.basename -}}
{{ printf "%s.%s" .Release.Name .Values.route.basename }}
{{- else -}}
{{- default .Release.Name .Values.nameOverride | trunc 54 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "gp-bke-runtime-minimal-application.hasVolumeMounts" -}}
{{- range .Values.configmaps -}}
    {{- if .mountPath -}}
        {{- true -}}
    {{- end -}}
{{- end -}}
{{- range .Values.secrets }}
    {{- if .mountPath -}}
        {{- true -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "gp-bke-runtime-minimal-application.volumeMounts" -}}
{{- range .Values.configmaps -}}
    {{- if .mountPath -}}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
    {{- end -}}
{{- end -}}
{{- range .Values.secrets }}
    {{- if .mountPath -}}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{ define "gp-bke-runtime-minimal-application.volumes" -}}
{{- range .Values.configmaps -}}
    {{- if .mountPath -}}
- name: {{ .name }}
  configMap:
    name: {{ .name }}
    {{- end -}}
{{- end -}}
{{- range .Values.secrets }}
    {{- if .mountPath -}}
- name: {{ .name }}
  secret:
    secretName: {{ .name }}
    {{- end -}}
{{- end -}}
{{- end -}}