# 🛠️ k8s-migrate

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
[![Shell Script](https://img.shields.io/badge/Language-Bash-blue)](https://www.gnu.org/software/bash/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-namespace--migrator-blue)](https://kubernetes.io/)

A lightweight Bash CLI utility to **migrate a namespace's resources between Kubernetes clusters** (contexts) using `kubectl`.

---

## 📆 What This Tool Does

`k8s-migrate.sh` interactively exports and applies Kubernetes resources from a specified namespace between two kube-contexts — allowing you to:

- Migrate applications from **dev ➔ prod**, **test ➔ staging**, etc.
- Sync environments quickly
- Prepare for cluster upgrades or provider migrations

It works using native `kubectl` commands and supports all common namespaced resources.

---

## 🚀 Quick Start

### ✅ Prerequisites

- `kubectl` installed and configured
- Both clusters defined in your `~/.kube/config`
- Access rights to export and apply resources

> Optional:
> - [`yq`](https://github.com/mikefarah/yq) for sanitizing exported YAML
> - `kubectl neat` for cleaning unnecessary fields

---

### 🧪 Demo

```bash
chmod +x k8s-migrate.sh
./k8s-migrate.sh
```

```text
Enter namespace to migrate: my-app
Enter source K8S context (from-cluster): dev-cluster
Enter target K8S context (to-cluster): prod-cluster

Select resources to migrate (space-separated or 'all'):
Available: deployments services configmaps secrets ingresses pvc all
> all

🔍 Migration Summary:
Namespace:        my-app
Source cluster:   dev-cluster
Target cluster:   prod-cluster
Resources:        deployments services configmaps secrets ingresses pvc

Proceed with migration? (y/n): y

📤 Exporting...
📥 Importing...
✅ Migration complete.
```

---

## 🔧 Supported Resources

- `deployments`
- `services`
- `configmaps`
- `secrets` ⚠️
- `ingresses`
- `pvc` (PersistentVolumeClaims)

You can select specific types or use `all` to migrate everything listed above.

---

## 🔐 Secret Handling

Secrets are exported and applied as-is. Be careful:
- **Do not** migrate `service account tokens` or `cloud provider credentials` unless necessary.
- Consider sanitizing secrets before applying them to another cluster.

---

## 📂 Temporary Files

All exported resources are saved to a temporary working directory (via `mktemp -d`) and applied from there. This folder is **not deleted automatically**, so you can inspect or archive it if needed.

---

## 🧱 Advanced Ideas

Want to improve or extend this?

- Add `--dry-run` support
- Sanitize YAML via `yq` or `kubectl neat`
- Support Helm releases or CRDs
- Use labels or selectors to filter resources
- Migrate RBAC (`RoleBinding`, `ServiceAccount`, etc.)

---

## 🧑‍💻 Author

Created by [@epolevov](https://github.com/epolevov)  
Maintained by the engineering team at [EMD Labs](https://emd.one)

---

## 📜 License

This project is licensed under the [MIT License](./LICENSE).

