# Contributing

How work is tracked and shipped in this repository. Terms follow [CONTEXT.md](CONTEXT.md); design decisions live in [docs/adr/](docs/adr/).

## Issues

Every issue carries exactly one `type:` label and at least one `area:` label, and every Task and Bug one `priority:` label. Nothing else classifies an issue.

| Mechanism | Use |
|---|---|
| Type | Set by the issue form. `type:feature`: a group of new functionality, the parent of Tasks. `type:task`: one piece of work ending in one pull request; research and decisions are Tasks closed by recording the answer. `type:bug`: something the project does wrong. |
| Area | Set in the sidebar. The `area:` labels and their scope are the [labels page](../../labels); each label's description says what it covers. `area:dev` covers CONTRIBUTING, AGENTS.md, GitHub templates and settings, CI, and the dev environment. Add an area with `gh label create area:<name> --description "<scope>" --color 1d76db`. |
| Priority | Set in the sidebar. `priority:urgent`: stops other work. `priority:high`: taken next among ready issues. `priority:medium`: the default. `priority:low`: waits until nothing else is ready. Blockers decide order first; Priority chooses among issues that are ready. |
| Sub-issue | Tasks sit under their Feature. |
| Relationships | Dependencies are set as **Blocked by** in the sidebar, never written in the body. |
| Close reason | completed, not planned, or duplicate. |
| Milestone | Created only once a release's contents are settled. |

Use the issue forms. Links to design documents are full URLs to `main`; plain text such as "ADR-0002" is not linked.

## Branches and pull requests

- One Task = one branch = one pull request. Branch name: `issue-<number>-<slug>`.
- Branch from `main` only, never from a branch that is not merged yet; starting a Task only once its blockers are closed makes this the normal case.
- Features have no branch: each Task branches from `main` and merges into `main`.
- The pull request title is a Conventional Commit summary; it becomes the commit on `main`.
- The pull request body starts with `Closes #<number>`, one line per issue it closes. The branch's issue must be one of them.
- Squash-merge by default. Use a merge commit only when every commit stands alone (a Conventional Commit message, and the code works at that commit), such as a move kept apart from the edits to the moved files; say so in the pull request body.
- Anything outside the Task's scope goes into a new issue, not into the same pull request.
- A design change is recorded in CONTEXT.md, an ADR, or `docs/` in the same pull request.

CI checks the title, the `Closes` lines, and the branch name (`pr-check`), and runs lint and tests (`ci`). The `main` ruleset requires both to pass and blocks direct pushes; see [ADR-0001](docs/adr/0001-checks-run-in-ci.md).

## Commits

- [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`. Summary in lowercase imperative, no trailing period. Breaking changes: `feat!:` or a `BREAKING CHANGE:` footer.
- No generated trailers such as `Co-Authored-By`.

## Development

```bash
uv sync
uv run ruff check
uv run ruff format --check
uv run pytest
```

## Releases

1. In the pull request, set the new version in `pyproject.toml`.
2. Merge.
3. Tag the resulting commit on `main` and push the tag. The tag runs `.github/workflows/release.yml`, which creates the GitHub Release with generated notes.

   ```bash
   git tag -a vX.Y.Z -m vX.Y.Z
   git push origin vX.Y.Z
   ```

Versions follow [Semantic Versioning](https://semver.org/). The pull request title's type picks the part: `fix:` is patch, `feat:` is minor, `feat!:` or a `BREAKING CHANGE:` footer is major. `docs:`, `chore:`, `refactor:`, and `test:` need no release.
