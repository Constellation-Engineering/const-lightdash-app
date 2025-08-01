#!/bin/bash
set -e # Exit immediately if a command fails.

# Define the absolute path to the installed binaries
BIN_DIR="/opt/render/project/src/node_modules/.bin"

echo "--- Running dbt dependencies ---"
$BIN_DIR/dbt deps --no-version-check

echo "--- Running Lightdash database migrations ---"
$BIN_DIR/dbt-lightdash-v2 migrate

echo "--- Starting Lightdash server ---"
$BIN_DIR/dbt-lightdash-v2 start