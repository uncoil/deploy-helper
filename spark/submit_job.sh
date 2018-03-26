#! /bin/bash

set -e

# should we verify that necessary variables are set?
source /deploy/conf

PROJECT_NAME=$GOOGLE_PROJECT_ID
CLUSTER=$CI_BRANCH
DEFAULT_ZONE=us-central1-a

echo project name: $PROJECT_NAME
echo cluster: $CLUSTER
echo default zone: $DEFAULT_ZONE

echo 'setting project'
gcloud config set project $PROJECT_NAME
echo 'setting zone'
gcloud config set compute/zone $DEFAULT_ZONE
echo $GOOGLE_AUTH_JSON > /tmp/keyfile.json
echo 'authenticating service account'
gcloud auth activate-service-account --key-file /tmp/keyfile.json --project $PROJECT_NAME

echo 'setting cluster'
gcloud config set container/cluster $CLUSTER
echo 'getting container creds'
gcloud container clusters get-credentials $CLUSTER

IMAGE_TAG=${CI_COMMIT_ID}
KUBERNETES_MASTER=k8s://https://35.184.11.111 # should be a map with staging/production keys

# clean up old job with same label
echo 'cleaning up old job'
pods=$(kubectl get pods -a -l jobName=${JOB_NAME} | grep -v 'NAME' | awk '{print $1}')
echo $pods
if [[ $pods ]]; then
  kubectl delete pod $pods
fi

# TODO: testing
TEST4=$(ls /opt)
echo "submit_job /opt $TEST4"
TEST5=$(ls /)
echo "submit_job / $TEST5"
TEST6=$(ls /lib_managed)
echo "submit_job /lib_managed $TEST6"
TEST9=$(ls /lib_managed/credentials)
echo "submit_job /lib_managed/credentials $TEST9"

# TODO: change the paths from /lib_managed to local:///opt/spark/lib_managed

# JAR_LIST=$(find /lib_managed -name '*.jar' | paste -sd , -)
JAR_LIST=$(find /lib_managed -name '*.jar' | while read line; do echo "local:///opt/spark$line"; done | paste -sd , -)
echo "jars: $JAR_LIST"

# TODO: testing
JAR_LIST="$JAR_LIST,local:///etc/hadoop/lib/gcs-connector-latest-hadoop2.jar"

echo 'starting spark job'
$SPARK_HOME/bin/spark-submit \
  --deploy-mode cluster \
  --class ${CLASS_NAME} \
  --master ${KUBERNETES_MASTER} \
  --jars "$JAR_LIST" \
  --conf spark.kubernetes.submission.waitAppCompletion=false \
  --conf spark.executor.instances=${EXECUTOR_INSTANCES} \
  --conf spark.kubernetes.driver.label.jobName=${JOB_NAME} \
  --conf spark.app.name=${JOB_NAME} \
  --conf spark.kubernetes.container.image=gcr.io/uncoil-io/spark-job-images/${JOB_NAME}:${IMAGE_TAG} \
  local:///opt/spark/work-dir/${JOB_NAME}.jar ${DATA_DIRECTORY}
