# VoxSmart specifics

## Names

- **VSP** is the VoxSmart Surveillance Portal.
- **VX1** is the new unified UI. **VCS** is the compliance product whose pages live in VX1.

## Kinds of customer

Order the tabs:

1. **VCS only**: no changes; they never see the VSP (Capture) pages.
2. **VSP only**: the VSP pages only.
3. **VCS and VSP**: both; the Capture group sits under the VCS groups.

## The app

- Sidebar groups: Home, Investigate, Configure (VCS), Capture with a "New" badge (VSP). VSP-only customers see only Capture.
- The new-interface banner ("You're using the new interface" + "Switch to the old interface") only shows on Capture pages.
- Browser tab titles come from `routes.tsx` in vs-fe-unified-ui-svc: `VoxSmart - <page title>`, e.g. `VoxSmart - Communications`, `VoxSmart - Login`.
- Deployed URLs look like `sandbox2.dev.voxsmart.ai/vx1/...` (VX1 served under `/vx1/` on the VSP host); the classic VSP is at the host root with hash routes, e.g. `/#/dashboard`.

## Behaviour to show correctly

- VSP has one session per browser, shared by the classic VSP and VX1: signing in to either signs you in to both.
- Org-wide SSO means SSO only: the VSP login shows just "Continue with SSO".
- VSP's SSO always lands on the classic VSP's dashboard, in the tab it ran in.
- Error messages follow the classic VSP (e.g. "Error, please try again.").
