#!/bin/bash
set -euo pipefail

applications=$(find ./chart/values -type f \( -name "*.yaml" -o -name "*.yml" \) -print | sort)
value_files=$(echo "$applications" | sed 's/^/-f /')
helm template argo-cd-app-of-apps ./chart/charts/parent-chart -f ./chart/values.yaml $value_files --output-dir rendered-manifests

# for chart in chart-a chart-b; do
#   for env in dev prod staging; do
#     helm template "$chart-$env" ./charts/$chart -f values/$env.yaml --output-dir rendered-manifests/$chart/$env
#   done
# done

for application_yaml in $applications; do
  echo "Rendering application: $application_yaml"
  appname=$(basename $(dirname "$application_yaml"))
  clusters=$(yq eval ".$appname.clusters[].name" "$application_yaml")
  for clustername in $clusters; do
    helm template "${appname}.${clustername}" \
      ./chart/charts/child-chart \
      -f ./chart/values.yaml \
      -f $application_yaml \
      --output-dir rendered-manifests/children/${appname}/${clustername} \
      --set only.cluster="$clustername"
  done
done
