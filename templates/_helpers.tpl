{{/*
차트 이름 반환
*/}}
{{- define "envoy-sidecar-demo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
fullname 생성 (release-name + chart-name, 63자 제한)
*/}}
{{- define "envoy-sidecar-demo.fullname" -}}
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
차트 레이블 (chart name + version)
*/}}
{{- define "envoy-sidecar-demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
공통 레이블
*/}}
{{- define "envoy-sidecar-demo.labels" -}}
helm.sh/chart: {{ include "envoy-sidecar-demo.chart" . }}
{{ include "envoy-sidecar-demo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
셀렉터 레이블
*/}}
{{- define "envoy-sidecar-demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "envoy-sidecar-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
