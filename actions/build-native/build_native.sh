#!/usr/bin/env bash
set -euo pipefail

# Builds sdist + cibuildwheel wheels for a compiled-extension project.
# Assumes the project's .venv has already been bootstrapped (see actions/env-setup)
# and that CIBW_* environment variables are set by the caller.
ROOT_DIR="$(pwd)"

if [ ! -d "$ROOT_DIR/.venv" ]; then
	echo "Missing .venv. Run the env-setup action first." >&2
	exit 1
fi

. .venv/bin/activate

echo "Preparing build output directory"
rm -rf dist
mkdir -p dist

echo "Running tox build environment (sdist + wheel)"
uv run tox -e build

echo "Running tox cibuildwheel environment (multiplatform wheels)"
uv run tox -e cibuildwheel

echo "Build artifacts placed in dist/"
