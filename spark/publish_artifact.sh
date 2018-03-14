#! /bin/bash

set -e

# should we verify that necessary variables are set?
source /deploy/conf

ARTIFACT_TAG="$CI_COMMIT_ID"

sbt package

gcloud auth activate-service-account --key-file /deploy/gcskey.json

gsutil cp target/scala-${SCALA_BASE_VERSION}/${DEFAULT_JAR} gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${ARTIFACT_TAG}.jar
gsutil cp target/scala-${SCALA_BASE_VERSION}/${DEFAULT_JAR} gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:latest.jar
