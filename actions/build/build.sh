#!/usr/bin/env bash
set -euo pipefail

# Builds distribution artifacts for the calling project. Assumes the
# project's .venv has already been bootstrapped (see actions/env-setup).
ROOT_DIR="$(pwd)"

if [ ! -d "$ROOT_DIR/.venv" ]; then
	echo "Missing .venv. Run the env-setup action first." >&2
	exit 1
fi

. .venv/bin/activate

echo "Preparing build output directory"
rm -rf dist
mkdir -p dist

echo "Running tox build environment"
uv run tox -e build

echo "Build artifacts placed in dist/"
