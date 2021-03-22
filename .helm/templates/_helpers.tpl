{{/* vim: set filetype=mustache: */}}
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dummy-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
app.kubernetes.io/name        The name of the application, ex.: mysql
app.kubernetes.io/instance    A unique name identifying the instance of an application , ex.: mysql-abcxzy
app.kubernetes.io/version     The current version of the application (e.g., a semantic version, revision hash, etc.) , ex.: 5.7.21
app.kubernetes.io/component   The component within the architecture, ex.: database, Payments
app.kubernetes.io/part-of     The name of a higher level application this one is part of, ex.: wordpress, GlobalTicket, Payments
app.kubernetes.io/managed-by  The tool being used to manage the operation of an application, ex.: helm
*/}}
{{- define "dummy-app.labels" -}}
helm.sh/chart: {{ include "dummy-app.chart" . }}
{{ include "dummy-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dummy-app.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.app.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.app.component }}
app.kubernetes.io/part-of: {{ .Values.app.name }}
{{- end }}
