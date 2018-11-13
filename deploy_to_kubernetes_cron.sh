#! /bin/bash

# NAME, commands
source /deploy/kubernetes/commands.sh && get_commands
source /deploy/kubernetes_deploy_base.sh

JOB_TEMPLATE="/deploy/kubernetes/cron.job.template.yaml"
TEMPORARY_JOB_FILE="/deploy/kubernetes/cron.job.yaml"

# PRIMARY_IMAGE
/deploy/kubernetes_deploy_base.sh

# `commands` are an associative array -- [COMMAND]=SCHEDULE

# Get all keys, each as a new string: "${!commands[@]}" 
for command in "${!commands[@]}"; do

  # Split string into array of strings
  split_command=($command)

  # Name will include last item of command, cannot include slashes.
  NAME="$NAME-${split_command[-1]}"

  export COMMAND="[${command}]"
  export SCHEDULE="${commands[$command]}"
  export NAME=$(echo $NAME | awk '{print tolower($0)}')

  echo COMMAND "$COMMAND"
  echo NAME "$NAME"
  echo SCHEDULE "$SCHEDULE"
  echo PRIMARY_IMAGE "$PRIMARY_IMAGE"
  
  # Delete old jobs.
  # Ignore exit code with pipe operator.
  kubectl delete cronjob $NAME || true
  
  /deploy/templater.sh ${JOB_TEMPLATE} > ${TEMPORARY_JOB_FILE}
  kubectl apply --record -f ${TEMPORARY_JOB_FILE}
  rm ${TEMPORARY_JOB_FILE}
done
