#!/bin/bash
# Will chedk if the Bitwarden Secrets Manager CLi is already installed, and install if requiured.

BIN_LOCATION="/tmp/bws"
RELEASE_VERSION="bws-v${PARAM_VERSION}"
SEMVER_VERSION="${PARAM_VERSION}"

function install() {
# Download release archive from git
curl --silent -L "https://github.com/bitwarden/sdk/releases/download/${RELEASE_VERSION}/bws-x86_64-unknown-linux-gnu-${SEMVER_VERSION}.zip" \
    --output "/tmp/bws-${SEMVER_VERSION}.zip"

unzip "/tmp/bws-${SEMVER_VERSION}.zip" -d "/tmp"

chmod +x "${BIN_LOCATION}"

# Check installed version
if [ ! "$($BIN_LOCATION --version)" == "bws ${SEMVER_VERSION}" ]; then

        echo "Error when trying to install bws cli"

else
        echo "bws cli has been installed! $($BIN_LOCATION --version)"

fi

}

# Check file exists
if [ -f "$BIN_LOCATION" ]; then

        # Check installed version
        if [ ! "$($BIN_LOCATION --version)" == "bws ${SEMVER_VERSION}" ]; then
        
                echo "Incorrect bws cli version installed. Installing..."
                install
        
        else
                echo "bws cli is installed and a the correct version! $($BIN_LOCATION --version)"
        
        fi

else
        echo "Bin doesnt exist. Installing..."
        install
fi