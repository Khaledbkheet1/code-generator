apiVersion: v1
kind: Namespace
metadata:
  labels:
    control-plane: controller
  name: ack-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ack-{{ .ServicePackageName }}-controller
  namespace: ack-system
  labels:
    control-plane: controller
spec:
  selector:
    matchLabels:
      control-plane: controller
  replicas: 1
  template:
    metadata:
      labels:
        control-plane: controller
    spec:
      containers:
      - command:
        - ./bin/controller
        args:
        - --aws-region
        - "$(AWS_REGION)"
        - --aws-endpoint-url
        - "$(AWS_ENDPOINT_URL)"
        - --enable-development-logging
        - "$(ACK_ENABLE_DEVELOPMENT_LOGGING)"
        - --log-level
        - "$(ACK_LOG_LEVEL)"
        - --resource-tags
        - "$(ACK_RESOURCE_TAGS)"
        - --watch-namespace
        - "$(ACK_WATCH_NAMESPACE)"
        image: controller:latest
        name: controller
        ports:
          - name: http
            containerPort: 8080
        resources:
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 100m
            memory: 200Mi
        env:
        - name: ACK_SYSTEM_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: AWS_REGION
          value: ""
        - name: AWS_ENDPOINT_URL
          value: ""
        - name: ACK_WATCH_NAMESPACE
          value: ""
        - name: ACK_ENABLE_DEVELOPMENT_LOGGING
          value: "false"
        - name: ACK_LOG_LEVEL
          value: "info"
        - name: ACK_RESOURCE_TAGS
          value: "services.k8s.aws/controller-version=%CONTROLLER_SERVICE%-%CONTROLLER_VERSION%,services.k8s.aws/namespace=%K8S_NAMESPACE%"
        securityContext:
          allowPrivilegeEscalation: false
          privileged: false
          runAsNonRoot: true
          capabilities:
            drop:
              - ALL
      terminationGracePeriodSeconds: 10
      serviceAccountName: {{ .ServiceAccountName }}
      hostIPC: false
      hostNetwork: false
      hostPID: false
