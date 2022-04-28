{{/*
Add nodeselector definition. Be aware about the indent.
*/}}
{{- define "infranodes.enabled" -}}
{{- if .Values.infranodes.enabled -}}
{{- println "nodeSelector:" -}}
{{- printf "node-role.kubernetes.io/infra: \"\"" | indent 8 -}}
{{- end -}}
{{- end -}}
