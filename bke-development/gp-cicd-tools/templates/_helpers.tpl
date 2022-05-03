{{- define "workflows.oauth-redirect-uri" -}}
{{- if .Values.workflows.route.hostname -}}
https://{{ .Values.workflows.route.hostname }}/oauth2/callback
{{- else -}}
https://{{ .Release.Name }}-{{ .Release.Namespace}}.${CLUSTERROUTERSUFFIX}.com/oauth2/callback
{{- end }}
{{- end }}

{{- define "workflows.sso-secret" -}}
{{- if .Values.sso.clientSecret -}}
{{- .Values.sso.clientSecret | b64enc | quote -}}
{{- else -}}
{{- randAlphaNum 32 | b64enc | quote  -}}
{{- end -}}
{{- end -}}