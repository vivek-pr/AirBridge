{{- define "airbridge.fullname" -}}
{{- .Release.Name -}}
{{- end -}}

{{/* Dag sync sidecar container */}}
{{- define "airbridge.dagSync.container" -}}
- name: dag-sync
  image: {{ .Values.dagSync.image }}
  command: ["/bin/sh","-c"]
  args:
    - |
      n=0
      while true; do
        if aws s3 sync s3://{{ .Values.dagSync.bucket }}{{ if .Values.dagSync.prefix }}/{{ .Values.dagSync.prefix }}{{ end }} {{ .Values.dags.path }}; then
          n=0
          sleep {{ .Values.dagSync.intervalSeconds }}
        else
          n=$((n+1))
          sleep $((2**n))
          if [ $n -ge {{ .Values.dagSync.retries }} ]; then
            exit 1
          fi
        fi
      done
  volumeMounts:
    - name: dags
      mountPath: {{ .Values.dags.path }}
{{- end -}}
