{{/*
Expand the name of the chart.
*/}}
{{- define "kafka-connect.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kafka-connect.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kafka-connect.build.imageStream" -}}
{{- if .Values.build.imageStreamOverride }}
{{- .Values.build.imageStreamOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" $name "build" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafka-connect.labels" -}}
helm.sh/chart: {{ include "kafka-connect.chart" . }}
{{ include "kafka-connect.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafka-connect.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafka-connect.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Annotations
*/}}
{{- define "kafka-connect.annotations" -}}
strimzi.io/use-connector-resources: 'true'
{{- if .Values.argocd }}
{{- if and (.Values.argocd.syncwave) (.Values.argocd.enabled) }}
argocd.argoproj.io/sync-wave: "{{ .Values.argocd.syncwave }}"
{{- end }}
{{- end }}
{{- end }}

{{/*
ArgoCD Syncwave
*/}}
{{- define "kafka-connect.argocd-syncwave" -}}
{{- if .Values.argocd }}
{{- if and (.Values.argocd.syncwave) (.Values.argocd.enabled) -}}
argocd.argoproj.io/sync-wave: "{{ .Values.argocd.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/*
Kafka Client Secret Name
*/}}
{{- define "kafka-connect.client-secret.name" }}
{{- $broker := .Values.broker | default "kafka" }}
{{- $secretName := printf "%s-client-secret" $broker }}
{{- $secretName }}
{{- end }}

{{/*
Kafka Client Secret Required?
*/}}
{{- define "kafka-connect.client-secret.required" }}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "kafka-connect.client-secret.name" . )) | default dict }}
{{- $output := "" }}
{{- if not $secretObj }}
{{- $output = "1" }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client Secret
*/}}
{{- define "kafka-connect.client-secret" }}
{{- $secretObj := (lookup "v1" "Secret" .Values.kafka.namespace (include "kafka-connect.client-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $bootstrapServer := (get $secretData "bootstrapServer") }}
{{- $securityProtocol := (get $secretData "securityProtocol") }}
{{- $saslMechanism := (get $secretData "saslMechanism") }}
{{- $clientId := (get $secretData "clientId") }}
{{- $clientSecret := (get $secretData "clientSecret") }}
bootstrapServer: {{ $bootstrapServer}}
securityProtocol: {{ $securityProtocol }}
saslMechanism: {{ $saslMechanism }}
clientId: {{ $clientId }}
clientSecret: {{ $clientSecret }}
{{- end }}

{{/*
Kafka Client Secret Namespace
*/}}
{{- define "kafka-connect.client-secret.namespace" }}
{{- if ( include "kafka-connect.client-secret.required" . ) }}
{{- .Values.kafka.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Kafka Bootstrap Server
*/}}
{{- define "kafka-connect.bootstrap-server" }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka-connect.client-secret.namespace" .) (include "kafka-connect.client-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $bootstrapServer := (get $secretData "bootstrapServer") | b64dec }}
{{- $bootstrapServer }}
{{- end }}

{{/*
Kafka Client Authentication
*/}}
{{- define "kafka-connect.authentication" }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka-connect.client-secret.namespace" .) (include "kafka-connect.client-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientId := (get $secretData "clientId") | b64dec }}
{{- $output := "" }}
{{- if $clientId }}
{{- $output = "1" }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client Id
*/}}
{{- define "kafka-connect.client-id" }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka-connect.client-secret.namespace" .) (include "kafka-connect.client-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientId := (get $secretData "clientId") | b64dec }}
{{- $clientId }}
{{- end }}

{{/*
Kafka Authentication type
*/}}
{{- define "kafka-connect.authentication-type" }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka-connect.client-secret.namespace" .) (include "kafka-connect.client-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $saslMechanism := (get $secretData "saslMechanism") | b64dec }}
{{- $output := "" }}
{{- if eq "PLAIN" $saslMechanism }}
{{- $output = "plain" }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Authentication TLS
*/}}
{{- define "kafka-connect.tls" }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka-connect.client-secret.namespace" .) (include "kafka-connect.client-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $securityProtocol := (get $secretData "securityProtocol") | b64dec }}
{{- $output := "" }}
{{- if eq "SASL_SSL" $securityProtocol }}
{{- $output = "1" }}
{{- end }}
{{- $output }}
{{- end }}
