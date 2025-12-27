{{/*
Expand the name of the chart.
*/}}
{{- define "iof.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "iof.fullname" -}}
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
{{- define "iof.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "iof.labels" -}}
helm.sh/chart: {{ include "iof.chart" . }}
{{ include "iof.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "iof.selectorLabels" -}}
app.kubernetes.io/name: {{ include "iof.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component-specific labels
*/}}
{{- define "iof.componentLabels" -}}
{{- $component := .component -}}
{{- $root := .root -}}
helm.sh/chart: {{ include "iof.chart" $root }}
app.kubernetes.io/name: {{ include "iof.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
app.kubernetes.io/component: {{ $component }}
{{- if $root.Chart.AppVersion }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $root.Release.Service }}
{{- end }}

{{/*
Component selector labels
*/}}
{{- define "iof.componentSelectorLabels" -}}
{{- $component := .component -}}
{{- $root := .root -}}
app.kubernetes.io/name: {{ include "iof.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
Image name helper
*/}}
{{- define "iof.image" -}}
{{- $registry := .root.Values.global.imageRegistry -}}
{{- $org := .root.Values.global.imageOrganization -}}
{{- $repo := .image.repository -}}
{{- $tag := .image.tag | default .root.Values.global.imageTag -}}
{{- printf "%s/%s/%s:%s" $registry $org $repo $tag }}
{{- end }}

{{/*
Database connection string
*/}}
{{- define "iof.databaseUrl" -}}
{{- if .Values.postgresql.external.enabled -}}
{{- printf "postgresql://%s:${DB_PASSWORD}@%s:%d/%s" .Values.postgresql.external.username .Values.postgresql.external.host (.Values.postgresql.external.port | int) .Values.postgresql.external.database }}
{{- else -}}
{{- printf "postgresql://postgres:${DB_PASSWORD}@iof-postgresql:5432/iof" }}
{{- end }}
{{- end }}

{{/*
Redis connection string
*/}}
{{- define "iof.redisUrl" -}}
{{- if .Values.redis.external.enabled -}}
{{- printf "redis://%s:%d" .Values.redis.external.host (.Values.redis.external.port | int) }}
{{- else -}}
{{- printf "redis://iof-redis:6379" }}
{{- end }}
{{- end }}
