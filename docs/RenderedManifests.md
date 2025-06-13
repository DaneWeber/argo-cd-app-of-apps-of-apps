# Flow of Rendered Manifests Pattern

Rather than manifest rendering occurring in the Argo CD instance, it occurs in a separate repository. This repository is updated by a CI pipeline when changes are made to the root repository.

```mermaid
sequenceDiagram
    participant upbranch as Upstream Branch
    participant upstream as Upstream Main
    participant rendbranch as Rendered Branch
    participant rendered as Rendered Main
    participant argocd as Platform Argo CD Instance
    participant teamargocd as Team Argo CD Instance
    participant teamrepo as Team Repository

    upstream->>upbranch: Devteam creates PR
    activate upbranch
    upbranch->>upbranch: Lint PR for valid YAML
    upbranch->>upstream: Code Owners approve and merge PR
    activate upstream
    upstream->>rendbranch: Render and create PR
    activate rendbranch
    rendbranch->>rendbranch: Lint PR for valid YAML
    rendbranch->>rendered: Pair review and merge PR
    activate rendered
    rendered->>argocd: Webhook to Argo CD
    argocd->>rendered: Fetch Rendered Manifests
    activate argocd
    argocd->>argocd: Sync Applications
    argocd->>teamargocd: Sync Applications
    teamargocd->>teamrepo: Fetch Team Manifests
    teamargocd->>teamargocd: Sync Applications
    deactivate upbranch
    deactivate upstream
    deactivate rendbranch
    deactivate rendered
    deactivate argocd
```
