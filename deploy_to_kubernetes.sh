#! /bin/bash

./kubernetes_deploy_base.sh

export PRIMARY_IMAGE=$PRIMARY_IMAGE

echo "Upgrading to $PRIMARY_IMAGE"
./deploy/templater.sh /deploy/kubernetes/deployment.template.yaml > deployment.yaml

echo "Applying new deployment"
kubectl apply --record -f deployment.yaml
echo "Done"
