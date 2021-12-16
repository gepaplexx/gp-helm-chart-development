{{- define "s2i.name" -}}
{{ default .Release.Name .Values.global.nameOverride }}{{- if .Values.global.runtime}}-{{ .Values.global.runtime }}{{- end}}
{{- end -}}

{{- define "s2i.labels" -}}
helm.sh/chart: {{ .Chart.Name }}
{{ include "s2i.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.openshift.io/runtime: {{ .Values.global.runtime }}
{{- end }}

{{- define "s2i.selectorLabels" -}}
app.kubernetes.io/name: {{ include "s2i.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "s2i.imageName" -}}
{{ default (include "s2i.name" .) .Values.image.name }}:{{ .Values.image.tag }}
{{- end -}}