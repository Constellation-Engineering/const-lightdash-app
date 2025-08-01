#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Add the local node_modules binaries to the PATH
export PATH="/opt/render/project/src/node_modules/.bin:$PATH"

# Run the setup and startup commands
echo "--- Running dbt dependencies ---"
dbt deps --no-version-check

echo "--- Running Lightdash database migrations ---"
dbt-lightdash-v2 migrate

echo "--- Starting Lightdash server ---"
dbt-lightdash-v2 start