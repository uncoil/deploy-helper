#! /bin/bash

set -e
APP_NAME=$CI_REPO_NAME
GOOGLE_CONTAINER_NAME=gcr.io/$GOOGLE_PROJECT_ID/$APP_NAME
PROJECT_NAME=$GOOGLE_PROJECT_ID
DEFAULT_ZONE=us-central1-a
CLUSTER=$CI_BRANCH

echo 'activating service account'
echo $GOOGLE_AUTH_JSON > /tmp/keyfile.json
gcloud auth activate-service-account $GOOGLE_AUTH_EMAIL --key-file /tmp/keyfile.json --project $PROJECT_NAME
echo 'setting project'
gcloud config set project $PROJECT_NAME
echo 'setting zone'
gcloud config set compute/zone $DEFAULT_ZONE

echo 'setting cluster'
gcloud config set container/cluster $CLUSTER
echo 'getting container creds'
gcloud container clusters get-credentials $CLUSTER

echo 'ci commit'
echo $CI_COMMIT_DESCRIPTION

# we are going to verify by checking package.json version against tag version
SAFE_COMMIT_DESCRIPTION=$(echo $CI_COMMIT_DESCRIPTION|tr -d '\n')
NEW_IMAGE_TAG="$CI_BRANCH.$SAFE_COMMIT_DESCRIPTION"
NEW_IMAGE="$GOOGLE_CONTAINER_NAME:$NEW_IMAGE_TAG"
export PRIMARY_IMAGE=$NEW_IMAGE

CONFIG_MAP_NAME="configmap.$CI_BRANCH.yaml"
FILE=/deploy/kubernetes/$CONFIG_MAP_NAME

if [ ! -e "$FILE" ]; then
    echo 'no configmap found to apply'
else
    echo "applying configmap $CONFIG_MAP_NAME"
    kubectl apply -f /deploy/kubernetes/$CONFIG_MAP_NAME
fi
