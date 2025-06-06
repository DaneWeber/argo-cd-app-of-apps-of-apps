# Argo CD App-of-Apps-of-Apps

The app-of-apps pattern is already in place for creating Argo CD instances in various namespaces for the use of different teams.

This project generates and synchronizes the Applications in Argo CD.

1. Root Application contains self and multiple Applications in the same management namespace, one for each Argo CD instance across the enterprise.
2. The first level of Applications each contain a single Application which belongs in the namespace of its respective Argo CD instance. This is necessary because all resources created by an Application must share the same destination namespace.
3. The Application created in the Argo CD instance namespace is itself the root Application for its Argo CD instance. It contains multiple Applications, as many as necessary for team using that Argo CD instance. While this Application is defined in the central repository, it watches a team-controlled repository for what should be synchronized in their Argo CD instance.

## Benefits

- GitOps applied across all Application definitions across the enterprise.
- Disasters of various severity can be recovered in minimal time. Once a Kubernetes cluster with the right namespaces and permissions is operational, Argo CD and the Application definitions will be re-created and service will be restored.
- Applications managed through this starting point are all discoverable by traversing the git codebases.

## Risks

- A single change in the root repository can have outsize impact across the enterprise, up to shuttind down all systems managed by Argo CD.

## Risk Mitigation

In order to reduce the risk of a single change causing widespread negative consequences, the following structure and policies will be adopted.

- `app-of-apps-of-apps` repository contains Helm/Kustomize definitions of the three layers of Applications.
  - Teams are able to create PRs in this repository to add or change the git repository/branch/path they will use for the app-of-apps in their own Argo CD instance. This should be infrequent (once when adopting Argo CD and then only when significantly changing how they manage their app-of-apps).
  - PRs include automated feedback via linting tools to verify that the changes result in valid YAML/etc.
  - The central team are Codeowners and require two-person reviews when merging to the `main` branch.
  - Merges to `main` have no immediate effect on Argo CD on running resources.
- Commits on `app-of-apps-of-apps`'s `main` branch trigger a CI pipeline (GitHub Actions in this scenario) which results in a PR in a separate repo: `app-of-apps-of-apps-rendered`.
  - GitHub Actions uses Helm/Kustomize to render the simple YAML to be applied.
  - The rendered YAML should be entirely made up of `Application` definitions.
  - The diff in the PR will explicitly show all changes and make very clear when a change in the original repo is affecting a large number of Applications.
  - Merging this PR is a double-check on already-merged PR that triggered it.

### Credit

Based on the following advice from Gerald Nunn, Raymond Wong, and [Christian Hernandez](https://github.com/christianh814/) via [CNCF Slack](https://cloud-native.slack.com/archives/C01TSERG0KZ/p1749150019226069) on 2025-06-07.

1. Use PRs and require a review by a different person before merging
2. Lint your PRs to validate, as much as it is possible outside a cluster, that what was modified is correct
3. Version your root app-of-app (i.e. set targetRevision) and only move it to a newer version when you feel comfortable doing so.
4. If the App-of-App is using a helm chart or kustomize to generate the children apps the [Rendered Manifests](https://akuity.io/blog/the-rendered-manifests-pattern) pattern provides another oppportunity to review changes. If it's just a flat list of Applications in a git repo then I would not sweat it.

Settings to consider:

- prevent empty applications
- warn on orphan
- protect resources from deletion with `.syncPolicy.preserveResourcesOnDeletion`

### References

- https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Controlling-Resource-Modification/#managed-applications-modification-policies
- https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-pruning-with-allow-empty-v18
- https://argo-cd.readthedocs.io/en/stable/user-guide/orphaned-resources/
- https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Application-Deletion/
- https://argo-cd.readthedocs.io/en/latest/user-guide/application-set/
- https://akuity.io/blog/the-rendered-manifests-pattern
