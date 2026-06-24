#!/usr/bin/env bash
set -euo pipefail

# Bootstraps uv/just/ssl_pydev for the calling project's CI run, then delegates
# the actual venv sync to ssl_pydev - the same CLI local devs use - so there's
# one source of truth for "how do we set up a project venv", not two copies.
# Called from action.yml with the caller project's repo as the working directory.

if ! command -v uv >/dev/null 2>&1; then
	curl -LsSf https://astral.sh/uv/install.sh | sh
	export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v just >/dev/null 2>&1; then
	curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
	export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v ssl-pydev >/dev/null 2>&1; then
	uv tool install ssl_pydev
fi

UV_TOOL_BIN="$(uv tool dir --bin)"
export PATH="$UV_TOOL_BIN:$PATH"
if [ -n "${GITHUB_PATH:-}" ]; then
	echo "$UV_TOOL_BIN" >> "$GITHUB_PATH"
fi

ssl-pydev setup-env "$@"
