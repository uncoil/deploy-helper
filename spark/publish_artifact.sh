#! /bin/bash

set -e

# should we verify that necessary variables are set?
source /deploy/conf

ARTIFACT_TAG="$CI_COMMIT_ID"

# TODO: testing
TEST7=$(ls /)
echo "publish_artifact / $TEST7"
TEST8=$(ls /lib_managed)
echo "publish_artifact /lib_managed $TEST8"

sbt package

# compress the dependencies
tar -czf lib_managed.tar.gz lib_managed

gcloud auth activate-service-account --key-file /deploy/gcskey.json

gsutil cp target/scala-${SCALA_MAJOR_VERSION}/${DEFAULT_JAR} gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${ARTIFACT_TAG}.jar
gsutil cp gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${ARTIFACT_TAG}.jar gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:latest.jar

gsutil cp lib_managed.tar.gz gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${ARTIFACT_TAG}_dependencies.tar.gz
gsutil cp gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${ARTIFACT_TAG}_dependencies.tar.gz gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:latest_dependencies.tar.gz
