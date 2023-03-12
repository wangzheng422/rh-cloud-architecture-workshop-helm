{{/*
Expand the name of the chart.
*/}}
{{- define "order-aggregator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "order-aggregator.fullname" -}}
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
{{- define "order-aggregator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "order-aggregator.labels" -}}
helm.sh/chart: {{ include "order-aggregator.chart" . }}
{{ include "order-aggregator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "order-aggregator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "order-aggregator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "order-aggregator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "order-aggregator.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Kafka Client Secret Name
*/}}
{{- define "kafka.client-connection-secret.name" }}
{{- $broker := .Values.broker | default "kafka" }}
{{- $secretName := printf "%s-client-secret" $broker }}
{{- $secretName }}
{{- end }}

{{/*
Kafka Client Secret Present?
*/}}
{{- define "kafka.client-connection-secret.present" }}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $output := "" }}
{{- if not $secretObj }}
{{- $output = "1" }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client Secret Namespace
*/}}
{{- define "kafka.client-connection-secret.namespace" }}
{{- if not ( include "kafka.client-connection-secret.present" . ) }}
{{- .Values.kafka.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Kafka Bootstrap Server
*/}}
{{- define "kafka.bootstrap-server" }}
{{- $output := "" }}
{{- if .Values.kafka.bootstrapServer }}
{{- $output = .Values.kafka.bootstrapServer }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $bootstrapServer := (get $secretData "bootstrapServer") | b64dec }}
{{- $output = $bootstrapServer }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client Authentication
*/}}
{{- define "kafka.authentication" }}
{{- $output := "" }}
{{- if .Values.kafka.userId }}
{{- $output = "1" }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientId := (get $secretData "clientId") | b64dec }}
{{- if $clientId }}
{{- $output = "1" }}
{{- end }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Security Protocol
*/}}
{{- define "kafka.security-protocol" }}
{{- $output := "" }}
{{- if .Values.kafka.securityProtocol }}
{{- $output = .Values.kafka.securityProtocol }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $securityProtocol := (get $secretData "securityProtocol") | b64dec }}
{{- $output = $securityProtocol }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Sasl Mechanism
*/}}
{{- define "kafka.sasl-mechanism" }}
{{- $output := "" }}
{{- if .Values.kafka.saslMechanism }}
{{- $output = .Values.kafka.saslMechanism }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $saslMechanism := (get $secretData "saslMechanism") | b64dec }}
{{- $output = $saslMechanism }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client Id
*/}}
{{- define "kafka.client-id" }}
{{- $output := "" }}
{{- if .Values.kafka.clientId }}
{{- $output = .Values.kafka.clientId }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientId := (get $secretData "clientId") | b64dec }}
{{- $output = $clientId }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client secret
*/}}
{{- define "kafka.client-secret" }}
{{- $output := "" }}
{{- if .Values.kafka.clientSecret }}
{{- $output = .Values.kafka.clientSecret }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientSecret := (get $secretData "clientSecret") | b64dec }}
{{- $output = $clientSecret }}
{{- end }}
{{- $output }}
{{- end }}
