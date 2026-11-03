import os
import subprocess
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / ".github" / "scripts" / "pr-check.sh"

# Fake `gh api repos/<repo>/issues/<n> --jq ...`: prints the issue state.
FAKE_GH = """#!/usr/bin/env bash
n=${2##*/}
case $n in
  1|2|3|11) echo open ;;
  9) echo closed ;;
  7) echo pr ;;
  *) exit 1 ;;
esac
"""


@pytest.fixture
def run(tmp_path):
    gh = tmp_path / "gh"
    gh.write_text(FAKE_GH)
    gh.chmod(0o755)

    def _run(title, body, branch):
        env = {
            **os.environ,
            "PATH": f"{tmp_path}{os.pathsep}{os.environ['PATH']}",
            "PR_TITLE": title,
            "PR_BODY": body,
            "PR_BRANCH": branch,
            "GH_REPO": "owner/repo",
            "GH_TOKEN": "x",
        }
        return subprocess.run(["bash", str(SCRIPT)], env=env, capture_output=True, text=True)

    return _run


@pytest.mark.parametrize(
    ("title", "body", "branch"),
    [
        ("feat: add search", "Closes #1\n\n## What changed", "issue-1-add-search"),
        ("feat: x", "Closes #1", "issue-1-x"),
        ("feat(cli)!: drop flag", "Closes #1", "issue-1-x"),
        ("fix: handle `nil` input", "Closes #1", "issue-1-x"),
        ("docs: x", "Closes #1\r\nmore", "issue-1-x"),
        ("chore: x", "Closes #1\nCloses #2", "issue-2-x"),
    ],
)
def test_passes(run, title, body, branch):
    result = run(title, body, branch)
    assert result.returncode == 0, result.stdout


@pytest.mark.parametrize(
    ("title", "body", "branch", "message"),
    [
        ("feat: add search.", "Closes #1", "issue-1-x", "Title must be"),
        ("feat: Add search", "Closes #1", "issue-1-x", "Title must be"),
        ("feature: add search", "Closes #1", "issue-1-x", "Title must be"),
        ("feat: x", "## What changed", "issue-1-x", "at least one line"),
        ("feat: x", "Closes #9", "issue-9-x", "got: closed"),
        ("feat: x", "Closes #7", "issue-7-x", "got: pr"),
        ("feat: x", "Closes #1", "issue-3-x", "does not close"),
        ("feat: x", "Closes #11", "issue-1-x", "does not close"),
        ("feat: x", "Closes #1", "feature/foo", "Branch must be"),
        ("feat: x", "Closes #1", "issue-1-Foo", "Branch must be"),
    ],
)
def test_fails(run, title, body, branch, message):
    result = run(title, body, branch)
    assert result.returncode == 1
    assert message in result.stdout
