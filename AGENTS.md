# AGENTS.md

Instructions for agents developing this repository. Rules for issues, branches, commits, and releases are in [CONTRIBUTING.md](CONTRIBUTING.md); vocabulary is in [CONTEXT.md](CONTEXT.md). Add a rule here only after a real failure shows it is needed.

## Starting an issue

1. Read the issue and its parent. Check that every issue it is Blocked by is closed; if not, stop and say which.
2. Read the design references the issue links to.
3. If the issue changes the design (architecture, tool choice, scope, anything expensive to reverse), present the design and get the user's agreement before writing code.
4. Work on branch `issue-<number>-<slug>` from `main`.

## While working

- Use the terms in CONTEXT.md, and none of the words it lists under _Avoid_.
- Stay inside the issue's Done when and Out of scope. Something else that needs fixing becomes a proposed new issue in your report, not a change.
- Run tools with `uv run`.

## Finishing

1. Run `uv run ruff check`, `uv run ruff format --check`, and `uv run pytest`.
2. Check every Done when item and report each one with its result.
3. Record design changes in CONTEXT.md, an ADR in `docs/adr/`, or `docs/` in the same pull request.
4. Before every commit, propose the message and let the user choose it. Add no trailers such as `Co-Authored-By`.
5. Open the pull request from the template, with `Closes #<number>` as the first line of the body.

## Never

- Commit secrets or `.env`.
