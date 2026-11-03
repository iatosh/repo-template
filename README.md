# repo-template

Starting point for a new repository: contribution rules, issue forms, a pull request template, and CI that checks them, for Python projects managed with uv.

## Use

1. Create the repository from this template and clone it.

   ```bash
   gh repo create <owner>/<name> --template iatosh/repo-template --public --clone
   cd <name>
   ```

2. Set up labels, merge options, and the `main` ruleset. GitHub copies only files from a template; labels, settings, and rulesets are not copied.

   ```bash
   scripts/bootstrap.sh
   ```

3. Add the project's areas as labels, each with the scope it covers.

   ```bash
   gh label create area:core --description "<what it covers>" --color 1d76db
   ```

4. Edit for the project:
   - `README.md`: replace this file.
   - `CONTEXT.md`: the project's name, one-line purpose, and terms.
   - `pyproject.toml`: `name` and `description`. Then `uv lock`.
   - `AGENTS.md`: add a rule under _Never_ for anything the project must not touch (data, shared drives).
   - Not Python: replace `.github/workflows/ci.yml` and the commands in CONTRIBUTING.md and AGENTS.md.

## What is in it

| Path | Purpose |
|---|---|
| `CONTRIBUTING.md` | Issues, branches, pull requests, commits, releases |
| `AGENTS.md` | How an agent works through an issue |
| `CONTEXT.md` | Project vocabulary and words to avoid |
| `docs/adr/` | Decision records; `0001` and `0002` explain the checks and labels below |
| `.github/ISSUE_TEMPLATE/` | Task, Feature, Decision, and Bug forms; each applies its `type:` label |
| `.github/pull_request_template.md` | `Closes #` first, then what changed and how it was checked |
| `.github/workflows/pr-check.yml` | Pull request title, `Closes` lines, branch name |
| `.github/workflows/ci.yml` | ruff and pytest |
| `.github/workflows/release.yml` | GitHub Release on a `v*` tag |
| `scripts/bootstrap.sh` | Labels, merge options, and the `main` ruleset for a new repository |

## Updating repositories made from it

A repository made from a template does not follow later changes to it. When a rule or check here changes, copy the change to each repository by hand. A templating tool with an update command (copier) was not used, because it puts template syntax into every file and this repository could no longer run its own checks.
