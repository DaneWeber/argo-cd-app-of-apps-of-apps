#!/bin/bash
set -euo pipefail

value_files=$(find ./chart/values -type f \( -name "*.yaml" -o -name "*.yml" \) -print | sort | sed 's/^/-f /')
helm template argo-cd-app-of-apps ./chart/charts/parent-chart $value_files --output-dir rendered-manifests
