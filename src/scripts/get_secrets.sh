#!/bin/bash
# Will use the installed bitwarden secrets manager cli to retreive a secret.
# Will save the retreived secret to the secrets file, which an be sourced later.
# The secret's key will be transformed to make it environment variable safe, this inclludes, coverting spaces to underscores, coberting dashes to underscores, casting to uppercase
# The secret ID must be provided as a PARAM_SECRET_ID environment variable.
# Requires that the environment variable BWS_ACCESS_TOKEN be set with a valid bws access token 
# Requires that the 'jq' utility for parsing JSON be installed

# Check jq installed
if [ ! "$(jq --version)" ]; then
    echo "jq utility is not installed. Please install before continuing"
    exit 1
fi

# Check if BWS_ACCESS_TOKEN environment variable is set
if [[ -z "${BWS_ACCESS_TOKEN}" ]]; then
    echo "BWS_ACCESS_TOKEN environment variable is not set. Please set before continuing."
    exit 1
fi

# Check if SECRET_IDS environment variable is set
if [[ -z "${PARAM_SECRET_IDS}" ]]; then
    echo "SECRET_IDS environment variable is not set. Please set before continuing."
    exit 1
fi

BIN_LOCATION="/tmp/bws"
SECRETS_DIR="${PARAM_SECRETS_DIR}"
SECRETS_FILE="${PARAM_SECRETS_FILE}"
SECRETS_PREFIX="${PARAM_SECRETS_PREFIX}"

SECRET_IDS="${PARAM_SECRET_IDS}"

function process_secret() {
SECRET_ID="$1"
        
if SECRET_DETAILS="$("${BIN_LOCATION}" secret get "${SECRET_ID}")"; then
        echo "Successfully got ${SECRET_ID}. Saving to secrets file"
        
        SECRET_RAW_KEY="$(echo "$SECRET_DETAILS" | jq -r .key)"
        SECRET_SAFE_KEY=$(echo "$SECRET_RAW_KEY" | tr ' ' '_' | tr '-' '_' | tr '[:lower:]' '[:upper:]');
        
        SECRET_RAW_VALUE="$(echo "$SECRET_DETAILS" | jq -r .value)"
        
        printf "%s=%s\n" "${SECRETS_PREFIX}${SECRET_SAFE_KEY}" "'${SECRET_RAW_VALUE}'" >> "$SECRETS_DIR/$SECRETS_FILE"
else 
        echo "Error when running secret get for secret ${SECRET_ID}"
        exit 1
fi

}

# Check secrets dir and file exists
if [ ! -d "$SECRETS_DIR" ]; then
  echo "$SECRETS_DIR does not exist. Creating"
  mkdir "$SECRETS_DIR"
  chmod 0700 "$SECRETS_DIR"
fi
if [ ! -f "$SECRETS_DIR/$SECRETS_FILE" ]; then
  echo "$SECRETS_DIR/$SECRETS_FILE does not exist. Creating"
  touch "$SECRETS_DIR/$SECRETS_FILE"
  chmod 0600 "$SECRETS_DIR/$SECRETS_FILE"
fi
# Clear existing secrets file before beginning to avoud dupes
echo -n "" > "$SECRETS_DIR/$SECRETS_FILE"

# Loop through secret IDs csv and process
for id in ${SECRET_IDS//,/ }
do
        echo "Processing secret ${id}"
        process_secret "${id}"
done
