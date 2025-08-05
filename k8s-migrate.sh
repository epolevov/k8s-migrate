#!/bin/bash

set -e

# Parse arguments
DRY_RUN=false
for arg in "$@"; do
  case $arg in
    --dryRun)
      DRY_RUN=true
      shift
      ;;
  esac
done

echo "Dry Run Mode:     $DRY_RUN"

### 🧾 Input Parameters
read -p "Enter namespace to migrate: " NAMESPACE
read -p "Enter source K8S context (from-cluster): " SRC_CONTEXT
read -p "Enter target K8S context (to-cluster): " DST_CONTEXT

### 📦 Resource Selection
declare -a ENTITIES=("deployments" "services" "configmaps" "secrets" "ingresses" "pvc" "all")
echo "Select resources to migrate (space-separated or 'all'):"
echo "Available: ${ENTITIES[*]}"
read -a SELECTED

# If 'all' is selected, override with full list
if [[ "${#SELECTED[@]}" -eq 1 && "${SELECTED[0]}" == "all" ]]; then
  SELECTED=("deployments" "services" "configmaps" "secrets" "ingresses" "pvc")
fi

### 📋 Migration Summary
echo -e "\n🔍 Migration Summary:"
echo "Namespace:        $NAMESPACE"
echo "Source cluster:   $SRC_CONTEXT"
echo "Target cluster:   $DST_CONTEXT"
echo "Resources:        ${SELECTED[*]}"
echo

read -p "Proceed with migration? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
  echo "Operation cancelled."
  exit 1
fi

TMP_DIR=$(mktemp -d)
echo "Temporary working directory: $TMP_DIR"

### 📤 Export from Source Cluster
echo -e "\n📤 Exporting resources from $SRC_CONTEXT..."
kubectl --context="$SRC_CONTEXT" get ns "$NAMESPACE" >/dev/null 2>&1 || {
  echo "Namespace '$NAMESPACE' not found in source cluster."
  exit 1
}

for RESOURCE in "${SELECTED[@]}"; do
  OUT="$TMP_DIR/${RESOURCE}.yaml"
  echo "  - Exporting $RESOURCE..."
  if [[ "$RESOURCE" == "pvc" ]]; then
    kubectl --context="$SRC_CONTEXT" -n "$NAMESPACE" get pvc -o yaml > "$OUT"
  else
    kubectl --context="$SRC_CONTEXT" -n "$NAMESPACE" get "$RESOURCE" -o yaml > "$OUT"
  fi
done

### 📥 Import into Target Cluster
echo -e "\n📥 Importing into $DST_CONTEXT..."
kubectl --context="$DST_CONTEXT" get ns "$NAMESPACE" >/dev/null 2>&1 || {
  echo "Creating namespace '$NAMESPACE' in target cluster..."
  kubectl --context="$DST_CONTEXT" create ns "$NAMESPACE"
}

for RESOURCE in "${SELECTED[@]}"; do
  YAML="$TMP_DIR/${RESOURCE}.yaml"
  if [[ -s "$YAML" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "  - [dry-run] Would apply $RESOURCE..."
      kubectl --context="$DST_CONTEXT" -n "$NAMESPACE" apply --dry-run=client -f "$YAML"
    else
      echo "  - Applying $RESOURCE..."
      kubectl --context="$DST_CONTEXT" -n "$NAMESPACE" apply -f "$YAML"
    fi
  else
    echo "  - Skipping $RESOURCE (no resources found)"
  fi
done

echo -e "\n✅ Migration complete."
