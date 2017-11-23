#! /bin/bash

JOB_TEMPLATE="/deploy/kubernetes/cron.job.template.yaml"
JOB_FILE="/deploy/kubernetes/cron.job.yaml"

source /deploy/kubernetes/commands.sh && get_commands
source /deploy/kubernetes_deploy_base.sh

/deploy/kubernetes_deploy_base.sh
export PRIMARY_IMAGE="${PRIMARY_IMAGE}"

for command in "${!commands[@]}"; do
  split_command=($command)
  formatted_command=\"${split_command[0]}\"
  for i in "${split_command[@]:1}"; do
    formatted_command="${formatted_command}, \"${i}\""
  done

  if [ -z "${NAME}" ]; then
    NAME="edgar-ecomm-${split_command[1]}"
  fi

  export COMMAND="[${formatted_command}]"
  export SCHEDULE="${commands[$command]}"
  export NAME="${NAME}"


  echo COMMAND "$COMMAND"
  echo NAME "$NAME"
  echo SCHEDULE "$SCHEDULE"
  echo PRIMARY_IMAGE "$PRIMARY_IMAGE"

  /deploy/templater.sh ${JOB_TEMPLATE} > ${JOB_FILE}
  kubectl apply --record -f ${JOB_FILE}
  rm ${JOB_FILE}
done