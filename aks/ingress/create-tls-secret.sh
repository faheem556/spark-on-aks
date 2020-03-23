#!/bin/bash

set -e

SCRIPT_DIR=$(dirname $0)
$SCRIPT_DIR/../../common/get-kubectl.sh

./kubectl -n spark create secret tls spark-host-tls \
  --cert=tls.crt \
  --key=tls.key

apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: spark-host-ingress
spec:
  tls:
  - hosts:
    - spark.russellreynolds.com
    secretName: spark-host-tls
  rules:
    - host: spark.russellreynolds.com
      http:
        paths:
        - path: /
          backend:
            serviceName: spark-service
            servicePort: 80
