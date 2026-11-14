---
name: update-dependencies
description: "Update a JavaScript repo's npm dependencies and clear `pnpm audit` / `npm audit` vulnerabilities in a fixed order: remove the security overrides, apply minor and patch bumps, take a major bump where one fixes a remaining vulnerability without much work, then add scoped overrides for whatever is left. Use when asked to update, bump or upgrade dependencies, fix audit or Dependabot vulnerabilities, or review overrides or resolutions. Also covers the branch, commits and PR for that work."
---

# /update-dependencies

Overrides force a version on packages that didn't ask for it, so they are the last resort. Each step below only handles what the previous one left, and every override that survives has a reason written down.

Before starting, check [Repo-specific rules](#repo-specific-rules) for the current repo, and read its `AGENTS.md` or `CLAUDE.md` for anything about dependencies, pins or overrides. Then set up the branch (see [Branch and commits](#branch-and-commits)).

Work in the user's tree. Try a major bump or an override that crosses a major version in a scratch worktree first (see [Scratch worktree](#scratch-worktree)), with just the checks for the tools it affects, then apply it to the user's tree and run the full [Verify](#verify) there. After each step, save a snapshot of the lockfile and every changed `package.json` to the scratchpad (`<scratchpad>/step-<n>/`).

The commands below are for pnpm. [Other package managers](#other-package-managers) lists the npm and Yarn equivalents.

## 0. Baseline

```sh
pnpm audit --json > <scratchpad>/audit-before.json
pnpm audit                      # the count to report back
pnpm outdated -r                # what is behind
```

In a pnpm workspace, run `pnpm audit` from the root. It audits the whole lockfile, so every workspace package is covered; there is no `-r` and no `--filter`.

Also save the peer warnings as they are now, so a new one can be spotted later. `pnpm install --frozen-lockfile` prints none, so resolve instead, in a scratch worktree of the starting commit: `pnpm install --resolution-only > <scratchpad>/peers-before.txt 2>&1`.

## 1. Remove the security overrides

Read `pnpm.overrides` in the root `package.json` and sort each entry into one of three kinds:

- **Security override**: forces a range to a release that fixes a published advisory. Delete it.
- **Compatibility pin**: holds a package at a version because a newer one breaks something (e.g. `"jsdom": "30.0.1"`). Keep it unless the reason is gone.
- **Bug-fix minimum**: looks like a security override (`"pkg@<x": "^x"`) but no advisory exists, because it was added to pull in a bug fix. Keep it.

To tell them apart, look up advisories for the package and read the history of the entry:

```sh
gh api "/advisories?affects=<pkg>&ecosystem=npm" --jq '.[] | [.ghsa_id, .severity, .summary] | @tsv'
git log --format='%h %s' -S '<entry>' -- package.json
```

Also check the repo's docs. When no reason can be found, keep the entry, and say in the report that the reason should be written down (in `AGENTS.md`, for example). To check a compatibility pin is still needed, run what it protects on the newer version in a scratch worktree, e.g. the tests that hit the bug.

Then `pnpm install` and confirm it took effect: the `overrides:` block at the top of `pnpm-lock.yaml` must match `package.json`. If it still lists the old entries, the install ran before the file was saved.

The audit count usually goes up after this step (e.g. 47 to 54, including criticals), because the old versions come back until step 2. That is expected; carry on.

Removing an override does not downgrade a locked version that still satisfies its parent's range, so some packages stay on the patched version on their own. Only the ones the parent's range excludes go back to an old version.

## 2. Minor and patch bumps

```sh
pnpm update -r          # moves every dependency to the newest version its range allows
pnpm outdated -r        # what is left needs a range change
```

- `pnpm update` rewrites the formatting of every `package.json` it touches, expanding one-line arrays and objects. Use the repo's own update script if it has one that formats afterwards, otherwise run the formatter, and read the `package.json` diffs for changes that are only formatting.
- Exact pins (no `^`) don't move with `pnpm update`. For each one, look for its reason as in step 1. With a reason, follow it. With none, bump it to the newest release in the same major version that is at least two weeks old (`pnpm view <pkg> time --json`), and keep it exact. Pins are often a supply-chain precaution, which the waiting time respects.
- A package listed under `pnpm.patchedDependencies` is patched for one exact version. When it changes version, redo the patch with `pnpm patch <pkg>@<version>` and check the patched behaviour still works, or the patch no longer applies.
- Compare the peer warnings `pnpm install` prints with the baseline from step 0. A new `unmet peer` usually means something else also needs a bump.
- Keep packages that are released together on the same version, in every workspace package. Some require it through an exact peer (`@vitest/coverage-v8` 5.1.0 needs `vitest` 5.1.0 exactly), and then the peer warning catches a mismatch. Others don't declare it (`@tanstack/query-core` and `@tanstack/react-query`), so only listing them shows it: `pnpm list -r --depth -1 "<pkg-a>" "<pkg-b>"`. A shared scope doesn't mean a shared release (`@tanstack/react-table` is released on its own), so check the packages' `repository` field when unsure.

Run `pnpm audit` again.

## 3. Major bumps that fix a vulnerability

For each remaining advisory, list every path that brings it in, not just the shortest one. One vulnerable package often has several parents, and an override scoped to only one of them leaves the others vulnerable:

```sh
pnpm audit --json | python3 -c '
import json, sys
d = json.load(sys.stdin)
seen = {}
for a in d["advisories"].values():
    for f in a["findings"]:
        for p in f["paths"]:
            parts = [x.strip() for x in p.split(">")]
            parent = parts[-2] if len(parts) > 1 else "(direct)"
            seen.setdefault((a["module_name"], f["version"]), {}).setdefault(parent, p)
for (name, version), parents in sorted(seen.items()):
    print(f"{name}@{version}")
    for parent, path in sorted(parents.items()):
        print(f"    via {parent}: {path}")
'
pnpm why <vulnerable-package> -r
```

Then look at the direct dependency at the top of each chain and at each package in between:

```sh
pnpm view <package> version                # latest stable
pnpm view <package> dist-tags              # canary, rc, next
pnpm view <package>@latest dependencies    # does the latest pull the patched version?
```

Take the major bump when all of these hold:

- it is a stable release (not canary, alpha or rc)
- its migration guide has no change the repo can't absorb with a small edit (read the guide, then search the repo for each breaking pattern)
- every check in [Verify](#verify) passes

Otherwise skip it and note the reason. Often the direct dependency is already on its latest release and an unmaintained package in between pins the old version (e.g. `sockjs` → `uuid@^8`); then go to step 4. Only consider majors that fix an open advisory; other outdated majors are a separate piece of work.

When the bumped tool is a peer of an internal library the user maintains, widen that library's peer range in its next release rather than overriding here.

## 4. Scoped overrides for the rest

Scope each override to the package that brings in the vulnerable version, one entry per parent from step 3, and cap it below the next major version:

```json
"sockjs>uuid": ">=11.1.1 <12",
"get-uri>basic-ftp": ">=6.2.1 <7"
```

- A scoped override only changes that one path. If another package later pulls in an old version, the audit flags it and it can be decided on its own.
- The cap stops a later install from jumping to a major version nothing was tested against.
- When the vulnerable version comes from many sibling packages (e.g. 16 `@jimp/*` plugins), a version selector (`"zod@<4.6.6": ">=4.6.6 <5"`) is acceptable. Say in the PR that it also catches any future package asking for the old version.
- Before crossing a major version, look for a fix in the parent's current major. Maintainers sometimes backport a fix to an older line under a tag like `v13-legacy` (`pnpm view <pkg> dist-tags`). Compare that release with the fixing one (`npm diff --diff=<pkg>@<old> --diff=<pkg>@<backport>`), then check two things before using it:
  - whether the advisory counts it as patched (`gh api /advisories/<GHSA-id> --jq '.vulnerabilities[] | [.vulnerable_version_range, .first_patched_version] | @tsv'`). If not, `pnpm audit` keeps flagging it until the advisory is updated.
  - whether the older line still depends on a vulnerable version of something else. glob 13.0.7 has the same AbortSignal fix as 14.0.2, but it still pulls in minimatch 10, which has no 10.x fix, so overriding to glob 14 fixes both in one entry.

  Use the backport when it is recognised as patched and brings in nothing else vulnerable. Otherwise cross the major, and say in the PR why the backport wasn't enough, since a reviewer is likely to ask.
- Check the patched version's module format and Node support, not only its number. `uuid` 12 and later can't be loaded with `require()`, so a parent that uses `require()` needs `<12`. Check with `pnpm view <pkg>@<version> type exports engines`.
- Don't use `pnpm audit --fix`: it writes global overrides with no upper bound.
- After adding the overrides, run `pnpm audit` again and repeat for any parent that only shows up now.

If no patched version works for the parent (the override breaks the tool, or the fix only exists in a major version the parent can't use), leave the vulnerability open and record why.

## Verify

Run everything the changed packages touch, through the same entry points the real tools use. A unit test passing is not enough: a tool may load modules differently from the test runner. For example, Docusaurus loads its TypeScript plugins through `jiti`, so a `zod` override once passed every vitest test and still broke the docs build.

For every override, also make sure the check actually runs the overridden code. A tool often only loads a dependency on one code path or above a size limit, so its check can pass without touching the new version. Find where the parent uses it (`grep -rn "require(\"<pkg>\")\|from \"<pkg>\"" node_modules/<parent>/`), and if no normal check reaches that, force the path or load the package directly. [Repo-specific rules](#repo-specific-rules) lists the known cases.

Use the repo's own checks from [Repo-specific rules](#repo-specific-rules) when it has an entry. Otherwise, work them out from the `package.json` scripts: lint, type check, every package's tests and the full build. Then look at what the changed packages are used for (`pnpm why <pkg> -r` and a search for the package name in scripts and config) and run each of those tools once: code generators, dev watchers, build plugins, CLIs. A tool that writes files into the repo should write to a scratch directory, and its output be compared with a baseline generated the same way on the starting commit (a fresh output folder can differ from the committed one in generator metadata alone).

When many tests fail at once with timeouts, the machine is probably busy, not broken:

1. Rerun only the failed files, and the same files on the baseline.
2. If timeouts remain on both sides, rerun with fewer workers (`--maxWorkers=3`).
3. Call it a regression only when a test fails on the candidate and passes on the baseline under the same settings. Then rerun the full suite once the machine is quieter.

Shell notes: on macOS, `timeout` doesn't exist, and in zsh an unquoted `$VAR` holding several file names is passed as one argument (use an array or `${=VAR}`).

## Triage what is left

`pnpm audit --prod` shows what reaches production dependencies. Build tooling can still appear there when a package lists it under `dependencies` (e.g. a docs site). For each open advisory, say whether the vulnerable code can receive outside input in practice (e.g. `deepmerge` in a build plugin only merges config from the repo) and how severe it is in that context. Confirm each "known open advisory" in [Repo-specific rules](#repo-specific-rules) with `pnpm why` rather than trusting the list, since it goes stale.

## Record

In the report (the PR description is shorter, see [Pull request](#pull-request)):

- the audit count before, after step 1, after step 2 and at the end, with the paths of the saved audit JSON
- every override, with the parent it applies to, the advisory and why the parent can't be bumped instead
- every compatibility pin and bug-fix minimum kept, with its reason, or a note that the reason is missing
- every exact pin bumped or left, with the reason
- every vulnerability left open, with the reason and the risk assessment
- the major bumps, with the migration guide link and what had to change
- each check and its result, and anything that couldn't be run (e.g. e2e that needs a real backend)
- the commits made

When a pin or workaround needs explaining in the code, add it to the repo's `AGENTS.md` (or wherever the repo keeps agent guidance) so the next update knows to keep it.

## Branch and commits

**Branch.** Always `fix/<TICKET>-fix-vulnerabilities` (e.g. `fix/UUI-2627-fix-vulnerabilities`), branched from the default branch, whatever the repo's other branches use.

To find the ticket:

1. If the user gave one, use it.
2. Otherwise, look in Jira for an open ticket assigned to them that matches the work (Atlassian MCP, `searchJiraIssuesUsingJql`):
   `assignee = currentUser() AND statusCategory != Done AND (summary ~ "vulnerab*" OR summary ~ "dependenc*" OR summary ~ "audit") ORDER BY updated DESC`
   If exactly one clearly matches, use it and name it in the first update so the user can correct it. If there are several, or none, ask the user for the ticket number before creating the branch.

**Commits.** Committing on this branch is fine, as separate commits when the steps make sense apart, e.g. (1) override removal and minor bumps, (2) exact pin bumps, (3) major bumps, (4) scoped overrides, (5) docs. Step 1 on its own usually raises the audit count, so commit it together with step 2. Build each commit from the step snapshots so its lockfile matches its `package.json`.

- Message: `fix(<TICKET>): <what the commit does>`, lower-case after the colon, e.g. `fix(UUI-2627): scope micromatch override to semantic-release-slack-bot`. The body says why (the advisory, why the parent can't be bumped).
- Always `fix`, never `chore`, even when only dev dependencies change. Semantic-release then cuts a patch release.
- Don't push unless asked.

## Pull request

When the user asks for a PR, use the `pr-voice` skill for wording and this format (from VoxSmartLtd/vs-fe-unified-ui-svc#1148). The title is `fix(<TICKET>): Fix vulnerabilities`.

```markdown
## Description

This PR:

- Removes the old overrides and bumps minor and patch versions
- Upgrades vitest to 5, which lets us drop the `jsdom` pin
- Adds scoped overrides for the vulnerabilities that can't be fixed by bumping

`pnpm audit` goes from 47 to 2. Neither is exploitable here, because both only run at build time on input we control:

- `zod` 3 from `jimp` ([CVE-2023-54404](https://github.com/advisories/GHSA-mrhx-c7xc-m3w5)): forcing zod 4 breaks the docs build, and `jimp` only uses it to validate our own image options
- `deepmerge` ([CVE-2026-93753](https://github.com/advisories/GHSA-gcqx-w48m-w2h4)): no patched version, and it only merges our build config

## Testing

<!--- Check if testing is required or a reason for not putting in tests -->

:x: - No, here's why:

Dependency updates only. All tests pass, the app and docs build, the generated API clients are unchanged, and a screenshot comparison of every page against `beta` showed no differences.
```

- One bullet per kind of change, in commit order, saying what it does for the repo rather than listing packages.
- The audit line gives before and after. When the end count is 0, say so and drop the list. Otherwise list each open advisory with its CVE or GHSA link and why it's not exploitable here.
- Keep the repo's PR template sections and comments (the `Testing` heading and its HTML comment). If the repo has its own template, fill that in the same spirit.
- The Testing paragraph names the checks that actually ran, and anything that couldn't (e.g. e2e that needs a real backend).

## Scratch worktree

```sh
git worktree add --detach <scratchpad>/<repo>-baseline HEAD
cd <scratchpad>/<repo>-baseline && pnpm install --frozen-lockfile
```

Copy in any untracked local config the repo needs to run (see [Repo-specific rules](#repo-specific-rules)). To try a change on top of the user's uncommitted work, copy their changed files in (`git diff --name-only HEAD` plus untracked files) before installing. Remove it afterwards with `git worktree remove --force <path>`.

## Other package managers

| | pnpm | npm | Yarn (berry) |
|---|---|---|---|
| Audit | `pnpm audit` | `npm audit` | `yarn npm audit --all --recursive` |
| Outdated | `pnpm outdated -r` | `npm outdated --all` | `yarn upgrade-interactive` |
| Update within ranges | `pnpm update -r` | `npm update` | `yarn up -R <pkg>` |
| Why | `pnpm why <pkg> -r` | `npm explain <pkg>` | `yarn why <pkg>` |
| Overrides field | `pnpm.overrides` | `overrides` | `resolutions` |
| Scoped override | `"parent>child": "<range>"` | `"parent": { "child": "<range>" }` | `"parent/child": "<range>"` |

Check the exact syntax against the package manager's docs before writing an override in npm or Yarn; the table is a starting point.

## Repo-specific rules

### `vs-fe-unified-ui-svc` (`~/projects/fe-ui` and its worktrees)

pnpm workspace with `app`, `user-guides` (Docusaurus), `shared`, `test-utils` and `e2e`. Follow the rules in its `AGENTS.md`, in particular never using ports 9000 and 9001. The `audit-mocked-app` crawl reports links to `localhost:9000` and `9001` (the `/help` iframe); those are only reported, not served by the check.

**Pins and workarounds to keep.** Check which of these the branch has: some only exist before or after the vitest 5 upgrade.

- **`jsdom` pin** (`"jsdom": "30.0.1"` in `pnpm.overrides`, and exact in `packages/app`): only on vitest 4. jsdom 30.1 breaks `FormData` and `Blob` request bodies under vitest 4 (`Cannot read properties of undefined (reading '_buffer')`). It goes with the vitest 5 upgrade, as `AGENTS.md` describes.
- **jest-dom matcher types** (`packages/app/src/types/vitest.d.ts` and `packages/user-guides/src/types/vitest.d.ts` extending `TestingLibraryMatchers`): only on vitest 5. Keep a copy in each package; a shared one in `test-utils` doesn't reach `user-guides`, which gets its own copy of vitest. Remove the jest-dom part once a jest-dom release includes https://github.com/testing-library/jest-dom/pull/742. On vitest 4 the app's file only declares the custom `toHaveExactText` matcher.
- **`"@radix-ui/react-select@<2.4.1": "^2.4.1"`**: not a security fix (it has no advisory). It works around a vx1-components issue that is fixed there but not yet merged (UUI-2511, `647ee2af`). Keep it until that fix is merged and released; the team removes it then.
- **`pnpm.packageExtensions`** for `@voxsmartltd/vx1-components` and `@voxsmartltd/frontend-utils`: a compatibility fix, not an override (see `AGENTS.md`).
- **`@easyops-cn/docusaurus-search-local`** is under `pnpm.patchedDependencies`.

**Updating.** Use `pnpm update-packages` instead of `pnpm update -r`: it runs `pnpm -r up` and then Biome over the workspace packages' `package.json` files. Biome leaves the root `package.json` alone, so collapse its `packageExtensions` entries back to one line each by hand.

**Released together, keep on one version**: `vitest` and `@vitest/*`; `@tanstack/query-core` and `@tanstack/react-query`; `@datadog/browser-logs`, `@datadog/browser-rum` and `@datadog/browser-rum-react`; every `@docusaurus/*` package.

```sh
pnpm list -r --depth -1 vitest "@vitest/*" "@tanstack/query-core" "@tanstack/react-query" "@datadog/browser-*" "@docusaurus/*"
```

**Exact pins with no recorded reason** (bump within the major, keep exact, two-week minimum age): `axios` (re-pinned in each vulnerability pass, so treat it as a supply-chain precaution), `@rsbuild/core`.

**Scratch worktree setup**

```sh
cp appconfig.json .env <worktree>/
cp packages/test-utils/.env.test <worktree>/packages/test-utils/
cd <worktree> && pnpm -F @vcs-ui2/shared -F @vcs-ui2/test-utils build   # the app and docs import their dist
```

**Checks**

```sh
pnpm lint
pnpm -F @vcs-ui2/app typecheck
pnpm -F @vcs-ui2/shared -F @vcs-ui2/test-utils build
pnpm test                                               # all packages
pnpm build                                              # app and docs, including the docs' postBuild plugins
```

`pnpm lint:ci` after `pnpm build` fails on the generated `packages/user-guides/.docusaurus/` folder; that is a repo issue, not the update. The full `pnpm test` takes several minutes and times out under load; see [Verify](#verify).

| Changed | Check |
|---|---|
| UI libraries (`@voxsmartltd/vx1-components`, Radix, Tailwind, React), `@rsbuild/core` | `pnpm build`, then the `audit-mocked-app` crawl and `smoke-flows.cjs`, with `MOCKED_APP_PORT` set |
| `axios` | the full `pnpm test` and the `smoke-flows.cjs` mutation flows |
| `@openapitools/openapi-generator-cli` or its dependencies (`glob`, `basic-ftp`) | in a scratch worktree, `pnpm -F @vcs-ui2/app exec openapi-generator-cli generate --generator-key vcs-api` and `--generator-key vcs-alerts-api` (both read committed spec files; `glob` only runs on the `--generator-key` path), plus `pnpm -F @vcs-ui2/app generate-vcs-intents-api`. Each output must match the committed `src/vcs-*-api` |
| `basic-ftp` | only loaded for `ftp://` proxy config, so no generator run reaches it: from the `get-uri` folder in `node_modules/.pnpm`, `require("basic-ftp")` and check `new Client()` has the methods `get-uri` calls (`access`, `list`, `lastMod`, `downloadTo`, `close`) |
| `nodemon` | `pnpm dev:watch:vx1-components` (needs the vx1 repo), or run `nodemon --watch <file> --exec "echo ran"` and change the file |
| Docusaurus, `jimp`, or packages used by `packages/user-guides/src/plugins` | `pnpm -F @vcs-ui2/user-guides build`; it should print `[manual-images] N images converted` |
| `tinypool` | Docusaurus only starts its worker pool for large sites, so a normal docs build doesn't load it. Force it: `DOCUSAURUS_SSG_WORKER_THREAD_COUNT=2 pnpm -F @vcs-ui2/user-guides build` |
| vitest, jsdom, Testing Library | the full `pnpm test`, and the file upload tests (`UploadDocumentsDialog`, both `NewSimulationDialog` tests, `UploadKeywordCsvDialog`) |
| `@playwright/test` | e2e needs a real backend, so it can't run here; say so in the report |

Always set `MOCKED_APP_PORT` to a free port for the `check-app-mocked` and `audit-mocked-app` scripts: without it they reuse any server already on 9100, which may be from another checkout, so you'd be checking the wrong code.

**Known open advisories (November 2026; confirm with `pnpm why`)**

- `zod` 3 from `jimp`: forcing zod 4 breaks `jimp` when Docusaurus loads it through `jiti`, and there is no patched zod 3.
- `deepmerge` from `@rsbuild/plugin-type-check` and `@svgr/plugin-svgo`: no patched version exists, and both only merge config from the repo. It shows under `--prod` because `user-guides` lists Docusaurus under `dependencies`.
