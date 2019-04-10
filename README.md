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
- You should be at 'What's next?', if not, find your project's settings.
- Hit 'General' on the navigation menu near the top right
- Under 'Keys', hit the copy button for the SSH Key, keep this tab open

### Setup codeship/github deploy key
- Open a new tab, log into the 'strawhousedev' Github account (credentials in the developer vault of 1pass) 
- Go to your project repository on github.com
- hit the settings tab on the near the top right 
- hit 'Deploy Keys' on the navigation menu
- remove the codeship key that is there (it was added by codeship)
- Go to the github user settings on the top right
- Go to SSH and GPG key.
- Add a new entry with the new project key. Suggested name: `codeship (your-project-name)`

### Setup Github webhooks
- Go to your project on github.com
- Go to Settings > Webhooks
- Add webhooks for slack, and statushero (copy the webhook URLs+configs from another project)

### Setup Codeship notifications
- Go to your project in Codeship
- Go to Settings > Notifications
- Add a Slack notification, copying the settings from another project

### Final project setup
- Load your project into your editor
- Copy the key.aes from the Codeship project settings into the `docker` folder
- Copy the gcp.env from another project into your `docker` folder
- From your project root, run `cd docker && jet encrypt gcp.env gcp.env.encrypted --key-path=key.aes && rm gcp.env`
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
