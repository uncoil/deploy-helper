#! /bin/bash

set -e

# should we verify that necessary variables are set?
source /deploy/conf

ARTIFACT_TAG="$CI_COMMIT_ID"

sbt package

# compress the dependencies
tar -czvf dependencies.tar.gz lib_managed/jars

gcloud auth activate-service-account --key-file /deploy/gcskey.json

gsutil cp target/scala-${SCALA_MAJOR_VERSION}/${DEFAULT_JAR} gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${ARTIFACT_TAG}.jar
gsutil cp gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${ARTIFACT_TAG}.jar gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:latest.jar

gsutil cp dependencies.tar.gz gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}_dependencies:${ARTIFACT_TAG}.tar.gz
gsutil cp gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}_dependencies:${ARTIFACT_TAG}.tar.gz gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}_dependencies:latest.tar.gz
