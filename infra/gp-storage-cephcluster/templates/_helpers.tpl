{{- define "infranodes.enabled" -}}
{{- if .Values.cephcluster.runOnInfra -}}
nodeSelector:
  node-role.kubernetes.io/infra: ""
{{- else -}}
nodeSelector:
  node-role.kubernetes.io/app: ""
{{- end -}}
{{- end -}}
