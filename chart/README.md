# Argo CD App-of-Apps Helm Chart

This Helm chart deploys a structured set of Argo CD Applications using the app-of-apps pattern. It creates a root Application that manages multiple child Applications across different namespaces, specifically designed for various environments and projects.

## Directory Structure

- `charts/`: This directory is intended for any sub-charts that may be included in this Helm chart. It is currently empty.
  
- `templates/`: Contains the YAML templates for the Argo CD Applications.
  - `root-application.yaml`: Defines the root Argo CD Application, specifying metadata, spec, and child Applications.
  - `platform-applications.yaml`: Generates Applications in the `platform-gitops` namespace, linking them to respective cluster Applications.
  - `cluster-applications.yaml`: Creates individual Applications for clusters (`devtest-east`, `devtest-west`, `prod-east`, `prod-west`) associated with projects (`collab-board`, `messaging`, `case-management`).

- `values.yaml`: Contains default configuration values for the Helm chart, including settings for the root Application, platform Applications, and cluster Applications.

- `Chart.yaml`: Provides metadata about the Helm chart, including the name, version, and description.

## Installation

To install the chart, use the following command:

```bash
helm install <release-name> ./chart
```

Replace `<release-name>` with your desired release name.

## Configuration

You can customize the chart by modifying the `values.yaml` file. This file allows you to set various parameters for the Applications, such as names, namespaces, and other relevant configurations.

## Prerequisites

- Ensure that you have a running Argo CD instance.
- Helm must be installed and configured to interact with your Kubernetes cluster.

## Usage

After installation, the root Application will manage the specified child Applications. You can view and manage these Applications through the Argo CD UI.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## GenAI

Note that all of the above was generated with GitHub Copilot.
