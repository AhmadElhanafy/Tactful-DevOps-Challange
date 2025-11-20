{{/* Helper to build image name */}}
{{- define "voting.fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}