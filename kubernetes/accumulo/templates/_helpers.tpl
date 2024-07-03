{{- /*

Copyright 2020-2022 Crown Copyright

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/ -}}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "accumulo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "accumulo.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "accumulo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "accumulo.labels" -}}
helm.sh/chart: {{ include "accumulo.chart" . }}
{{ include "accumulo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "accumulo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "accumulo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "accumulo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "accumulo.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "accumulo.zookeepers" -}}
  {{- if .Values.zookeeper.enabled -}}
    {{ template "accumulo.callSubChartTemplate" (list . "zookeeper" "zookeeper.image") }}
  {{- else -}}
    {{- required ".Values.zookeeper.enabled = false, so .Values.zookeeper.externalHosts must be set" .Values.zookeeper.externalHosts }}
  {{- end -}}
{{- end -}}

{{- define "accumulo.callSubChartTemplate" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 | splitList "." }}
{{- $template := index . 2 }}
{{- $values := $dot.Values }}
{{- range $subchart }}
{{- $values = index $values . }}
{{- end }}
{{- include $template (dict "Chart" (dict "Name" (last $subchart)) "Values" $values "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}

{{- define "accumulo.hdfsNamenodeHostname" -}}
  {{- if .Values.hdfs.enabled -}}
    {{ template "accumulo.callSubChartTemplate" (list . "hdfs" "hdfs.fullname") }}-namenode-0.{{ template "accumulo.callSubChartTemplate" (list . "hdfs" "hdfs.fullname") }}-namenodes
  {{- else -}}
    {{ required ".Values.hdfs.namenode.hostname needs to be set as .Values.hdfs.enabled = false" .Values.hdfs.namenode.hostname }}
  {{- end -}}
  :{{ .Values.hdfs.namenode.ports.clientRpc }}
{{- end -}}
