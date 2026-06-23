# fishnet Helm chart

Deploy [fishnet](https://github.com/niklasf/fishnet) — the distributed Stockfish
analysis client for [lichess.org](https://lichess.org) — on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.x
- A fishnet registration key from <https://lichess.org/get-fishnet>

## Install

Inline key:

```sh
helm install fishnet ./fishnet-helm --set key.value=YOUR_FISHNET_KEY
```

Or reference an existing Secret:

```sh
kubectl create secret generic fishnet --from-literal=KEY=YOUR_FISHNET_KEY
helm install fishnet ./fishnet-helm --set key.existingSecret=fishnet
```

## Configuration

| Key | Default | Description |
| --- | --- | --- |
| `replicaCount` | `1` | Number of fishnet worker pods. |
| `image.repository` | `niklasf/fishnet` | Image repository. |
| `image.tag` | `""` | Image tag. Defaults to chart `appVersion` (`latest`). |
| `image.pullPolicy` | `Always` | Image pull policy. |
| `key.value` | `""` | Inline fishnet key, rendered into a chart-managed Secret. |
| `key.existingSecret` | `""` | Name of an existing Secret holding the key. Takes precedence over `key.value`. |
| `key.secretKey` | `KEY` | Key within the Secret holding the fishnet key. |
| `resources` | `7` CPU / `1512Mi` mem (limits = requests) | Pod resource requests/limits. |
| `strategy` | RollingUpdate 25%/25% | Deployment update strategy. |
| `extraEnv` | `[]` | Extra environment variables. |
| `nodeSelector` / `tolerations` / `affinity` | `{}` / `[]` / `{}` | Scheduling controls. |
| `serviceAccount.create` | `false` | Create a ServiceAccount. |

You must set either `key.value` or `key.existingSecret`; otherwise install fails fast.

## Resources

fishnet is CPU-bound. The defaults request 7 CPUs per pod, matching a dedicated
node. Tune `resources` and `replicaCount` to your cluster.

## Uninstall

```sh
helm uninstall fishnet
```
