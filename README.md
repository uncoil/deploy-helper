# docker-ci-submodule

This project is a collection of docker deployment helper scripts. When creating a new project, follow the steps below to include this project as a submodule and to complete basic setup steps for your project.

### Include deploy-helper as a submodule

- Copy the URL for this repo with the Clone or download button on Github.com
- Go into the local directory for your project
- Create a docker/ directory if you don't already have one
- Run `git submodule add <git@github.com...> docker/deploy-helper`

### Create a new project on Codeship

- https://app.codeship.com/orgs/uncoil/projects/new
- Select Uncoil for organization and select your project's repository, proceed to the next step
- Select Pro, complete the setup

### Setup Codeship notifications

- Go to your project in Codeship
- Go to Settings > Notifications
- Add a Slack notification, copying the settings from another project

### Setup Github webhooks

- Go to your project on github.com
- Go to Settings > Webhooks
- Add webhooks for slack, and statushero (copy the webhook URLs+configs from another project)

### Final project setup

- Load your project into your editor
- Copy the key.aes from the Codeship project settings into the `docker` folder
- Copy the gcp.env from another project into your `docker` folder
- From your project root, run `cd docker && jet encrypt gcp.env gcp.env.encrypted --key-path=key.aes && rm gcp.env && rm key.aes`
- Copy `docker/id_github_deployment.rsa` from another project into your `docker` folder
- Add or create your `Dockerfile.app` and `local-compose.yaml` files in the `docker` folder
- Create `codeship-services.yml` and `codeship-steps.yml` in the project root (see other repositories for examples)
- Create a `test.sh` at the root of your project, this script will be responsible for setting up and running your project's test suite.
- Create a folder called `kubernetes` in the `docker` folder and add your deployment templates (see other projects for examples):

  - configmap.production.yaml
  - configmap.staging.yaml
  - deployment.template.yaml
  - service.yaml

  For cronjobs deployments:

  - commands.sh
  - cron.job.template.yaml

### Projects with a web server

- You should have a `docker/kubernetes/service.yaml` file that defines a NodePort service. If you don't, copy one from another project (insights, user-manager, etc).
- The service needs to be manually created the first time you deploy to staging and production.
- Ensure you are in the correct environment with `kubectl config set current-context [context]`.
- Create the service with `kubectl apply -f docker/kubernetes/service.yaml`.
