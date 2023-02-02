{{- define "Chart.name" -}}
{{ default .Release.Name .Values.global.nameOverride }}
{{- end -}}

{{- define "Chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "Chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "Chart.imageName" -}}
{{ .Values.image.name }}:{{ .Values.image.tag }}
{{- end -}}

{{- define "Chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}
{{ include "Chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}