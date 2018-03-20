#! /bin/bash

set -e

# should we verify that necessary variables are set?
source /deploy/conf

BRANCH=$(cd /git; git rev-parse --abbrev-ref HEAD)
HASH=$(cd /git; git rev-parse ${BRANCH})

gsutil cp gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${HASH}.jar /opt/spark/work-dir/${JOB_NAME}.jar