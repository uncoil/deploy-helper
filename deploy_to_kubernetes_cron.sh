#! /bin/bash

# NAME, `commands`
source /deploy/kubernetes/commands.sh && get_commands
source /deploy/kubernetes_deploy_base.sh

JOB_NAME=$NAME
JOB_TEMPLATE="/deploy/kubernetes/cron.job.template.yaml"
TEMPORARY_JOB_FILE="/deploy/kubernetes/cron.job.temporary.yaml"

# PRIMARY_IMAGE
/deploy/kubernetes_deploy_base.sh

# `commands` is an associative array -- [COMMAND]=SCHEDULE
# `command_names` is an optional associative array for command names -- [COMMAND]=NAME

# Get all keys, each as a new string: "${!commands[@]}"
for command in "${!commands[@]}"; do
  # Split string into array of strings
  command_strings=($command)

  # Start comma seperated values with first value.
  command_csv="${command_strings[0]}"

  # `:1` -- Start loop at second value.
  for i in "${command_strings[@]:1}"; do
    # Append new values with comma.
    command_csv="${command_csv}, \"${i}\""
  done

  # Use the command_names value for this command if it was set;
  # otherwise, use the last token of the command for the name.
  if [ -z ${command_names[$command]} ]; then
    # Name will include last item of command, cannot include slashes.
    NAME="$JOB_NAME-${command_strings[-1]}"
  else
    # Use the defined command name
    NAME="$JOB_NAME-${command_names[$command]}"
  fi

  export COMMAND="[${command_csv}]"
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
