#! /bin/bash

set -e

# should we verify that necessary variables are set?
source /deploy/conf

BRANCH=$(cd /git; git rev-parse --abbrev-ref HEAD)
HASH=$(cd /git; git rev-parse ${BRANCH})

gsutil cp gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${HASH}.jar /opt/spark/work-dir/${JOB_NAME}.jar
gsutil cp gs://uncoil-artifacts/${JOB_NAME}/${JOB_NAME}:${HASH}_dependencies.tar.gz /opt/spark/work-dir/lib_managed.tar.gz

tar -xzf /opt/spark/work-dir/lib_managed.tar.gz -C /opt/spark
rm /opt/spark/work-dir/lib_managed.tar.gz

# TODO: testing
TEST1=$(ls /opt)
echo "pull_artifact /opt $TEST1"
TEST2=$(ls /opt/spark)
echo "pull_artifact /opt/spark $TEST2"
TEST3=$(ls /opt/spark/work-dir)
echo "pull_artifact /opt/spark/work-dir $TEST3"
