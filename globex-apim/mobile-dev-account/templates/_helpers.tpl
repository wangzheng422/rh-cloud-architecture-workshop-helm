{{/*
Expand the name of the chart.
*/}}
{{- define "mobile-dev-account.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mobile-dev-account.fullname" -}}
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
{{- define "mobile-dev-account.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mobile-dev-account.labels" -}}
helm.sh/chart: {{ include "mobile-dev-account.chart" . }}
{{ include "mobile-dev-account.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mobile-dev-account.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mobile-dev-account.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mobile-dev-account.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mobile-dev-account.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ArgoCD Syncwave
*/}}
{{- define "mobile-dev-account.secret.argocd-syncwave" -}}
{{- if .Values.secret.argocd }}
{{- if and (.Values.secret.argocd.syncwave) (.Values.secret.argocd.enabled) -}}
argocd.argoproj.io/sync-wave: "{{ .Values.secret.argocd.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/*
ArgoCD Syncwave
*/}}
{{- define "mobile-dev-account.developeraccount.argocd-syncwave" -}}
{{- if .Values.developeraccount.argocd }}
{{- if and (.Values.developeraccount.argocd.syncwave) (.Values.developeraccount.argocd.enabled) -}}
argocd.argoproj.io/sync-wave: "{{ .Values.developeraccount.argocd.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/*
ArgoCD Syncwave
*/}}
{{- define "mobile-dev-account.developeruser.argocd-syncwave" -}}
{{- if .Values.developeruser.argocd }}
{{- if and (.Values.developeruser.argocd.syncwave) (.Values.developeruser.argocd.enabled) -}}
argocd.argoproj.io/sync-wave: "{{ .Values.developeruser.argocd.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}
