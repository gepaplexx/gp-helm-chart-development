{{- define "gpApp.name" -}}
{{ default .Release.Name .Values.global.nameOverride }}
{{- end -}}

{{- define "gpApp.defaultImageName" -}}
{{ default .Release.Name .Values.global.nameOverride }}{{- if .Values.global.runtime}}-{{ .Values.global.runtime }}{{- end}}
{{- end -}}

{{- define "gpApp.labels" -}}
helm.sh/chart: {{ .Chart.Name }}
{{ include "gpApp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.openshift.io/runtime: quarkus
{{- end }}

{{- define "gpApp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gpApp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "gpApp.imageName" -}}
{{ default (include "gpApp.defaultImageName" .) .Values.image.name }}:{{ .Values.image.tag }}
{{- end -}}