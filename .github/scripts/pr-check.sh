#!/usr/bin/env bash
# Checks pull request metadata against CONTRIBUTING.md.
# Inputs (env): PR_TITLE, PR_BODY, PR_BRANCH, GH_REPO, GH_TOKEN
set -uo pipefail

fail=0
err() { echo "::error::$1"; fail=1; }

title_re='^(feat|fix|docs|refactor|chore|test)(\([a-z0-9-]+\))?!?: [a-z0-9`](.*[^.])?$'
if [[ ! $PR_TITLE =~ $title_re ]]; then
  err "Title must be '<type>: <lowercase summary without trailing period>' (got: $PR_TITLE)"
fi

issues=$(printf '%s\n' "$PR_BODY" | tr -d '\r' | grep -oE '^Closes #[0-9]+$' | grep -oE '[0-9]+' || true)
if [[ -z $issues ]]; then
  err "Body must contain at least one line 'Closes #<issue-number>'"
fi
for n in $issues; do
  state=$(gh api "repos/$GH_REPO/issues/$n" --jq 'if .pull_request then "pr" else .state end' 2>/dev/null || echo missing)
  [[ $state == open ]] || err "Closes #$n: must be an open issue (got: $state)"
done

if [[ $PR_BRANCH =~ ^issue-([0-9]+)-[a-z0-9-]+$ ]]; then
  grep -qx "${BASH_REMATCH[1]}" <<<"$issues" ||
    err "Branch $PR_BRANCH is for #${BASH_REMATCH[1]}, which the body does not close"
else
  err "Branch must be issue-<number>-<slug> (got: $PR_BRANCH)"
fi

exit $fail
