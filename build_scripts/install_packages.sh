#!/bin/bash
# This script installs build-time requirements based on environment variables
# PY_REQUIREMENTS is a comma-separated list of package names

PY_REQUIREMENTS="$1"
NOTEBOOKS_DIR="$2"

# Create notebooks directory if it doesn't exist
mkdir -p "${NOTEBOOKS_DIR}"

if [ ! -z "${PY_REQUIREMENTS}" ]; then
    UNIQUE_ID=$(date +%s%N | md5sum | head -c 8)
    IFS=',' read -ra PACKAGES <<< "${PY_REQUIREMENTS}"
    
    for package in "${PACKAGES[@]}"; do
        echo "$package" >> "/tmp/py-requirements.${UNIQUE_ID}.txt"
    done
    
    if [ -f "/tmp/py-requirements.${UNIQUE_ID}.txt" ]; then
        pip install -r "/tmp/py-requirements.${UNIQUE_ID}.txt" > /notebooks/build.log 2>&1 || true
        mv "/tmp/py-requirements.${UNIQUE_ID}.txt" "/notebooks/py-requirements.${UNIQUE_ID}.txt"
    fi
fi 