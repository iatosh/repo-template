#!/usr/bin/env bash
# One-time setup for a repository created from this template.
# Creates the classification labels, removes GitHub's default labels, and sets merge options.
# Safe to run again. Usage: scripts/bootstrap.sh [owner/repo]   (default: the current repo)
set -euo pipefail

repo=${1:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}
echo "Bootstrapping $repo"

label() { gh label create "$1" --repo "$repo" --color "$2" --description "$3" --force >/dev/null && echo "  label $1"; }

label type:feature   a2eeef "A group of new functionality, the parent of Tasks"
label type:task      0e8a16 "One piece of work ending in one pull request"
label type:bug       d73a4a "Something the project does wrong"
label priority:urgent b60205 "Stops other work"
label priority:high   d93f0b "Taken next among ready issues"
label priority:medium fbca04 "The default"
label priority:low    c5def5 "Waits until nothing else is ready"
label area:dev        1d76db "CONTRIBUTING, AGENTS.md, GitHub templates and settings, CI, dev environment"

for l in bug documentation duplicate enhancement "good first issue" "help wanted" invalid question wontfix; do
  gh label delete "$l" --repo "$repo" --yes >/dev/null 2>&1 && echo "  removed $l" || true
done

gh api -X PATCH "repos/$repo" --silent \
  -F allow_squash_merge=true \
  -F allow_merge_commit=true \
  -F allow_rebase_merge=false \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=BLANK \
  -f merge_commit_title=PR_TITLE \
  -f merge_commit_message=BLANK \
  -F delete_branch_on_merge=true
echo "  merge: squash or merge commit, titled by the PR; branches deleted after merge"

# Protect the default branch: changes arrive only through pull requests whose checks pass.
# Repository admins may bypass only when merging a pull request (e.g. CI itself is broken).
ruleset=$(cat <<'JSON'
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
  "bypass_actors": [{"actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "pull_request"}],
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": false,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": false,
      "allowed_merge_methods": ["squash", "merge"]}},
    {"type": "required_status_checks", "parameters": {
      "strict_required_status_checks_policy": false,
      "required_status_checks": [{"context": "pr-check"}, {"context": "ci"}]}}
  ]
}
JSON
)
id=$(gh api "repos/$repo/rulesets" --jq '.[] | select(.name == "main") | .id')
if [[ -n $id ]]; then
  gh api -X PUT "repos/$repo/rulesets/$id" --input - --silent <<<"$ruleset"
else
  gh api -X POST "repos/$repo/rulesets" --input - --silent <<<"$ruleset"
fi
echo "  ruleset main: pull request with passing pr-check and ci required; no force push or deletion"

echo "Done. Add project areas with: gh label create area:<name> --description \"<scope>\" --color 1d76db"
