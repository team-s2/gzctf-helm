{{/*
Expand the name of the chart.
*/}}
{{- define "gzctf.name" -}}
{{- default .Chart.Name .Values.gzctf.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gzctf.fullname" -}}
{{- if .Values.gzctf.fullnameOverride }}
{{- .Values.gzctf.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.gzctf.nameOverride }}
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
{{- define "gzctf.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gzctf.labels" -}}
helm.sh/chart: {{ include "gzctf.chart" . }}
{{ include "gzctf.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gzctf.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gzctf.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gzctf.serviceAccountName" -}}
{{- if .Values.gzctf.serviceAccount.create }}
{{- default (include "gzctf.fullname" .) .Values.gzctf.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.gzctf.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database connection string
*/}}
{{- define "gzctf.databaseConnectionString" -}}
{{- if .Values.gzctf.config.database.host -}}
{{- printf "Host=%s;Database=%s;Username=%s;Password=%s" .Values.gzctf.config.database.host .Values.gzctf.config.database.name .Values.gzctf.config.database.username .Values.gzctf.config.database.password -}}
{{- else if .Values.postgresql.enabled -}}
{{- printf "Host=%s:5432;Database=%s;Username=%s;Password=%s" (printf "%s-db" (include "gzctf.fullname" .)) .Values.gzctf.config.database.name .Values.gzctf.config.database.username .Values.gzctf.config.database.password -}}
{{- else if (index .Values "postgresql-ha").enabled -}}
{{- printf "Host=%s-postgresql-ha-pgpool:5432;Database=%s;Username=%s;Password=%s" .Release.Name (index .Values "postgresql-ha").postgresql.database (index .Values "postgresql-ha").postgresql.username (index .Values "postgresql-ha").postgresql.password -}}
{{- else -}}
{{- printf "Host=gzctf-db:5432;Database=%s;Username=%s;Password=%s" .Values.gzctf.config.database.name .Values.gzctf.config.database.username .Values.gzctf.config.database.password -}}
{{- end -}}
{{- end }}

{{/*
Redis connection string
*/}}
{{- define "gzctf.redisConnectionString" -}}
{{- if .Values.gzctf.config.redis.host -}}
{{- printf "%s,abortConnect=%t" .Values.gzctf.config.redis.host .Values.gzctf.config.redis.abortConnect -}}
{{- else if .Values.garnet.enabled -}}
{{- printf "%s-garnet:6379,abortConnect=%t" (include "gzctf.fullname" .) .Values.gzctf.config.redis.abortConnect -}}
{{- else if (index .Values "redis-ha").enabled -}}
{{- if (index .Values "redis-ha").haproxy.enabled -}}
{{- printf "%s-redis-ha-haproxy:6379,password=%s,abortConnect=%t" .Release.Name (index .Values "redis-ha").redisPassword .Values.gzctf.config.redis.abortConnect -}}
{{- else -}}
{{- printf "%s-redis-ha:6379,password=%s,abortConnect=%t" .Release.Name (index .Values "redis-ha").redisPassword .Values.gzctf.config.redis.abortConnect -}}
{{- end -}}
{{- else -}}
{{- printf "gzctf-garnet:6379,abortConnect=%t" .Values.gzctf.config.redis.abortConnect -}}
{{- end -}}
{{- end }}

{{/*
Storage connection string (MinIO/S3)
*/}}
{{- define "gzctf.storageConnectionString" -}}
{{- if .Values.gzctf.config.storage.connectionString -}}
{{- .Values.gzctf.config.storage.connectionString -}}
{{- else if and .Values.gzctf.config.storage.enabled .Values.minio.enabled -}}
{{- printf "minio.s3://serviceUrl=%s-minio:9000;accessKey=%s;secretKey=%s;bucket=%s" .Release.Name .Values.minio.rootUser .Values.minio.rootPassword (index .Values.minio.buckets 0).name -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end }}
