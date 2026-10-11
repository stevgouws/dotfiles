---
name: team-membership
description: Add or remove a VoxSmart user from a team (Source, Nexus, etc.) across voxsmart-devops and vs-infrastructure-live-root. Use when asked to change someone's team membership, open the matching PRs, or explain why Slack/Datadog team pings did not change after a PR merged.
---

# Team membership changes

Changing a user's team touches two repos. Open one PR per repo, leave both in draft, and hand back the links.

## Where membership lives

| System | File | Repo |
|---|---|---|
| GitHub teams | `terraform/github/people/<first>-<last>.yml` | voxsmart-devops |
| SSO user teams (drives Tailscale groups and subnet access, Aurora users) | `shared/org/users/users.hcl` | vs-infrastructure-live-root (local clone: `~/projects/infra-live-root`) |
| Slack user groups (`@vs_<team>`) and Datadog teams | Entra ID group `team_vsmt_<team>` | **Not in any repo.** Read-only data source in the `slack` and `entra` modules of vs-infrastructure-modules. Needs an Entra admin. |

Team definitions (names, Entra group overrides, Tailscale `allow_access_subnets`) are in `shared/org/teams/teams.hcl` in live-root. The GitHub team definitions are in `terraform/github/teams/<team>.yml` in voxsmart-devops.

Reference PRs for the pattern:
- voxsmart-devops #582 and #707
- vs-infrastructure-live-root #863 and #1508

## Workflow

1. **Find the current state first.** Show the user's current team list in both files before editing. If removing a team would leave the SSO entry with `teams = []`, stop and ask what it should become. Do not guess.
2. **Branch from a fresh fetch of origin main** in each repo. Branch name pattern: `feat/<verb>-<first>-<from|to>-<team>-team`, e.g. `feat/remove-steven-from-nexus-team`. Use the same branch name in both repos.
3. **Make the minimal edit.** Only the user's own entry. Do not touch other users or reformat the file.
4. **Commit** with a `feat(): ...` conventional-commit title, e.g. `feat(): Remove Steven Gouws from Nexus team`. No Jira key unless one was given.
5. **Push and open a draft PR** against `main` with `gh pr create --draft`.
6. **Return both PR links** and a one-line summary of each diff.

## PR description style

- One terse sentence. Example: `This PR removes Steven Gouws from the Nexus team` or `This PR removes Steven Gouws from the Nexus team and adds them to the Source team`.
- Do not list remaining teams or other derived state.
- **No Claude footer**, no "Generated with Claude Code" line, no emoji.
- Use they/them for the user.

## Always flag

- Slack and Datadog team membership will not change from these PRs. Tell the user to get an Entra admin to update `team_vsmt_<team>`.
- If the live-root change swaps one team for another, mention that Tailscale subnet access follows the new team's `allow_access_subnets`.

## Tooling notes

- `gh` calls fail inside the sandbox with a TLS certificate error from the filtering proxy. Run `gh` and `git push` with the sandbox disabled.
- `git grep` and `git log -G'<handle>'` are the fastest way to locate a user's entries. Steven's identifiers are `steven.gouws@voxsmart.com`, GitHub `stevgouws`, file `steven-gouws.yml`.
