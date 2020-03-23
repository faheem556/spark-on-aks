#!/bin/bash

if ! ./kubectl version --client > /dev/null;
then
  echo "Download kubectl"
  arch=linux
  if [[ "$OSTYPE" == "darwin"* ]]; then
    arch=darwin
  elif [[ "$OSTYPE" == "win32" ]]; then
    arch=windows
  fi
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/$arch/amd64/kubectl
  chmod +x ./kubectl
  ./kubectl version --client
fi