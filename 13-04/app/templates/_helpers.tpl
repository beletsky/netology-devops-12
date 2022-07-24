{{- define "app.instance" -}}
{{- if .Values.instance -}}
-{{- .Values.instance -}}
{{- end -}}
{{- end -}}

{{- define "app.backendName" -}}
backend{{- include "app.instance" . }}
{{- end }}

{{- define "app.backendLabel" -}}
backend{{- include "app.instance" . }}
{{- end }}

{{- define "app.dbName" -}}
db{{- include "app.instance" . }}
{{- end }}

{{- define "app.dbLabel" -}}
db{{- include "app.instance" . }}
{{- end }}

{{- define "app.frontendName" -}}
frontend{{- include "app.instance" . }}
{{- end }}

{{- define "app.frontendLabel" -}}
frontend{{- include "app.instance" . }}
{{- end }}
