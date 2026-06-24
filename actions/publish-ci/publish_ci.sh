#!/usr/bin/env bash
set -euo pipefail

# CI publish script - uploads dist/ via twine using credentials from the environment.
ROOT_DIR="$(pwd)"

if [ ! -d "$ROOT_DIR/.venv" ]; then
	echo "Missing .venv. Run the env-setup action first." >&2
	exit 1
fi

. .venv/bin/activate

if [ -z "${TWINE_USERNAME-}" ] || [ -z "${TWINE_PASSWORD-}" ] || [ -z "${TWINE_REPOSITORY_URL-}" ]; then
	echo "Missing publishing credentials (TWINE_USERNAME / TWINE_PASSWORD / TWINE_REPOSITORY_URL)" >&2
	exit 1
fi

if [ ! -d dist ] || [ -z "$(ls -A dist 2>/dev/null)" ]; then
	echo "No artifacts found in dist/ - nothing to publish" >&2
	exit 1
fi

echo "Publishing artifacts from dist/ using twine"
python -m twine upload --non-interactive --repository-url "$TWINE_REPOSITORY_URL" dist/*

echo "Publish finished"
