# ssl_ci

Single source of truth for CI/CD logic shared across the `Swarm-Systems-Lab` GitHub
organization. Projects generated from `ssl_py_template` (and the template itself) call
into this repository instead of vendoring CI YAML and shell scripts in every project.

## Structure

```
.github/workflows/
  ci.yml                 # workflow_call: test / pre-commit / lint / security / typecheck
  publish.yml            # workflow_call: build + publish to PyPI on tag push
  docs.yml                # workflow_call: build docs + deploy to GitHub Pages on tag push
  template-metatests.yml  # workflow_call: ssl_py_template's own template-generation tests

actions/
  env-setup/      # composite action: native build deps + uv-managed venv bootstrap
  build/          # composite action: build dist/ artifacts via tox
  publish-ci/     # composite action: twine upload using TWINE_* env vars
  validate-docs/  # composite action: sanity-check a built mkdocs site/
```

Project-specific commands (`just test`, `just lint`, `just typecheck`, `just docs-build`,
...) stay in each project's own `justfile` — they're rendered per-project by the
copier template and know about that project's package name, tox envs, etc. `ssl_ci`
only owns the parts that are identical across every project: environment bootstrap,
building, publishing, and docs validation/deploy.

## Versioning

Releases are tagged `vX.Y.Z`, and the moving major tag (`v1`, `v2`, ...) is force-moved
to the latest compatible release, the same way `actions/checkout@v4` works. Calling
workflows pin to the major tag (`@v1`) so fixes roll out automatically; breaking changes
bump the major tag.

To cut a release:

```bash
git tag -fa v1.3.0 -m "v1.3.0"
git push origin v1.3.0
git tag -f v1 v1.3.0
git push origin v1 --force
```

## Using this repo from a project

```yaml
# .github/workflows/ci.yml in a calling project
name: CI
on:
  push:
    branches: ["**"]
  pull_request:
jobs:
  ci:
    uses: Swarm-Systems-Lab/ssl_ci/.github/workflows/ci.yml@v1
```

```yaml
# .github/workflows/publish.yml in a calling project
name: Publish
on:
  push:
    tags: ["v*"]
jobs:
  publish:
    uses: Swarm-Systems-Lab/ssl_ci/.github/workflows/publish.yml@v1
    secrets: inherit
```

```yaml
# .github/workflows/docs.yml in a calling project
name: Docs
on:
  push:
    tags: ["v*"]
jobs:
  docs:
    permissions:
      contents: read
      pages: write
      id-token: write
    uses: Swarm-Systems-Lab/ssl_ci/.github/workflows/docs.yml@v1
```

See the org-level setup notes in the migration PR description / chat history for how
repository visibility and Actions access policy were configured.
