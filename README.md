## docker-ci-submodule

#### Steps for codeship Kubernetes setup

Create a new project on codeship
- https://app.codeship.com/orgs/uncoil/projects/new
- Select Uncoil for organization and the project repository
- Select Pro


Open a new tab, log into the 'strawhousedev' Github account (credentials in the developer vault of 1pass) 
- Go to your project repository on github.com
- hit the settings tab on the near the top right 
- hit 'Deploy Keys' on the navigation menu

TODO: The guide says to delete the existing codeship key, that doesn't make much sense to me (continuing below).

- hit 'Add Deploy Key' near the top right
- Add a new entry with the new project key.


Tab back to your codeship project, you should be at 'What's next?', if not, find your project's settings.
- Hit 'General' on the navigation menu near the top right
- Under 'Keys', hit the copy button for the SSH Key 


Tab Back to Github

TODO: With above TODO in mind, add another SSH entry here as well? (This step may not be nessecary)

- Go to the github user settings on the top right
- Go to SSH and GPG key.


Load your project into your editor
- Copy the key.aes from your codeship project settings into the `docker` folder
- Copy the gcp.env from another project into your `docker` folder
- `cd docker && jet encrypt gcp.env gcp.env.encrypted --key-path=key.aes && rm gcp.env`
- Add or create your `dockerfile.app` and `local-compose.yaml` files in the `docker` folder
- Create `codeship-services.yml` and `codeship-steps.yml` in the project root (see other repositories for examples)
- Create a `test.sh` at the root of your project, this script will be responsible for setting up and running your project's test suite.
- Create a folder called `kubernetes` in the `docker` folder and add your deployment templates (see other projects for examples):
  - configmap.production.yaml
  - configmap.staging.yaml
  - deployment.template.yaml
  - service.yaml

  Not required:
  - commands.sh
  - cron.job.template.yaml
