{{- define "infranodes.enabled" -}}
{{- if .Values.cephcluster.runOnInfra -}}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: node-role.kubernetes.io/infra
        operator: Exists
{{- else -}}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: node-role.kubernetes.io/app
        operator: Exists
{{- end -}}
{{- end -}}
