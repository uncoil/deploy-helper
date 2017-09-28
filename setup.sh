GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;3=1m'
NC='\033[0m' # No Color

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR/../.."


function prompt {
  echo "Press any key to continue..." && read -p "" -n1 -s
}
die() { echo "$@" 1>&2 ; exit 1; }

function instruct {
  echo "${GREEN}$1 ${NC}"
}
function notify {
  echo "${YELLOW}$1 ${NC}"
}

function templater {
  CMD="$DIR/templater.sh $DIR/$1 > $PROJECT_ROOT/$2"
  eval $CMD
}

function checkdeps {
  jet version >/dev/null 2>&1 || { echo >&2 "${RED} Jet not installed.  Aborting."; exit 1; }
}

[[ -f "gcp.env" ]] || die "expected gcp.env file to be in project root"

checkdeps

instruct "Create a new \"Pro\" project on codeship, then press any key to go to the next step"
prompt
instruct "Go to the codeship settings and get the project aes key, enter it here."

while [[ -z "$AES_KEY" ]]
do
    read -s -p "Codeship AES Key: " AES_KEY
done

instruct "What is the project name"
read PROJECTNAME
export PROJECTNAME=$PROJECTNAME
notify "setting up \"$PROJECTNAME\""
notify "Doing setup..."
notify "\tMaking dirs"
mkdir -p docker
mkdir -p docker/kubernetes
notify "\tadding docker-ci-submodule"

[[ -f "codeship-services.yml" ]] || templater "files/codeship/codeship-services.yml" "codeship-services.yml"
[[ -f "codeship-steps.yml" ]] || templater "files/codeship/codeship-steps.yml" "codeship-steps.yml"
[[ -f "docker/dockerfile.app" ]] || templater "files/dockerfiles/basic-node.dockerfile" "docker/dockerfile.app"

echo $AES_KEY > "$DIR/key.aes"
jet encrypt "$PROJECT_ROOT/gcp.env" "$PROJECT_ROOT/docker/gcp.env.encrypted" --key-path="$DIR/key.aes"


[[ -f "docker/kubernetes/configmap.staging.yml" ]] || templater "files/kubernetes/configmap.staging.yaml" "docker/kubernetes/configmap.staging.yml"
[[ -f "docker/kubernetes/configmap.production.yaml" ]] || templater "files/kubernetes/configmap.production.yaml" "docker/kubernetes/configmap.production.yml"

export PRIMARY_IMAGE="{{PRIMARY_IMAGE}}" # hack to make sure we leave the find-replace for the PRIMARY_IMAGE

prompt="Select deployment type"
options=("Static Files" "Node with Mysql" "Simple Node")

PS3="$prompt "
select opt in "${options[@]}"; do

    case "$REPLY" in

    1 ) templater "files/kubernetes/files/deployments/nginx-static.deployment.template.yaml" "docker/kubernetes/deployment.template.yaml"; break;;
    2 ) templater "files/kubernetes/files/deployments/node-mysql.deployment.template.yaml" "docker/kubernetes/deployment.template.yaml"; break;;
    3 ) templater "files/kubernetes/files/deployments/simple-node.deployment.template.yaml" "docker/kubernetes/deployment.template.yaml"; break;;
    esac

done

echo "Setup done, you will have to tweak your dockerfile.app and likely the docker/kubernetes/deployment.template.yaml"

