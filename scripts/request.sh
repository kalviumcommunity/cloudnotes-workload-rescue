#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ "${KUBECONFIG:-}" == "$PWD/.lab/kubeconfig" ]] || { echo 'Source .lab/env.sh first; ambient cluster not permitted.' >&2; exit 1; }
namespace=${NAMESPACE:-cloudnotes-rescue}
method=${1:?Usage: bash scripts/request.sh GET|POST /path [note-text]}
path=${2:?Supply request path}
[[ "$path" == /* ]] || { echo 'Path must start with /' >&2; exit 1; }
kubectl -n "$namespace" exec -i client -- python - "$method" "http://cloudnotes.${namespace}.svc.cluster.local${path}" "${3:-}" < scripts/request.py
