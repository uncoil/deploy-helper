#! /bin/bash

./kubernetes_deploy_base.sh

echo "Applying new deployment"
kubectl apply --record -f deployment.yaml
echo "Done"
