#!/usr/bin/env sh

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
LOCAL_FILE=${1:-"$REPO_ROOT/data/processed/user_behavior_sample.csv"}
HDFS_BASE=${2:-"/user/${HDFS_USER:-${USER:-current}}/cufe-bdmma2026s"}
HDFS_FILE="$HDFS_BASE/data/processed/user_behavior_sample.csv"

if ! command -v hdfs >/dev/null 2>&1; then
  printf '%s\n' "Error: hdfs command not found. Please ensure Hadoop is installed and HDFS is available in PATH." >&2
  exit 1
fi

if [ ! -f "$LOCAL_FILE" ]; then
  printf '%s\n' "Error: local file not found: $LOCAL_FILE" >&2
  exit 1
fi

hdfs dfs -mkdir -p "$(dirname "$HDFS_FILE")"
hdfs dfs -put -f "$LOCAL_FILE" "$HDFS_FILE"

printf 'Uploaded %s to %s\n' "$LOCAL_FILE" "$HDFS_FILE"
