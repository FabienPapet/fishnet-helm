{{/*
Expand the name of the chart.
*/}}
{{- define "fishnet.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fishnet.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fishnet.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fishnet.labels" -}}
helm.sh/chart: {{ include "fishnet.chart" . }}
{{ include "fishnet.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fishnet.selectorLabels" -}}
app: {{ include "fishnet.name" . }}
app.kubernetes.io/name: {{ include "fishnet.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the secret holding the fishnet key.
*/}}
{{- define "fishnet.secretName" -}}
{{- if .Values.key.existingSecret }}
{{- .Values.key.existingSecret }}
{{- else }}
{{- include "fishnet.fullname" . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "fishnet.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fishnet.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
