{{/*
Add nodeselector definition. Be aware about the indent.
*/}}
{{- define "infranodes.enabled" -}}
{{- if .Values.infranodes.enabled -}}
nodeSelector:
  node-role.kubernetes.io/infra: ""
{{- end -}}
{{- end -}}
