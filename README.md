<img src=".github/assets/relayaid-icon.png" width="72" height="72" alt="RelayAid logo">

# RelayAid

Report offline. Coordinate live. Keep the whole response traceable.

RelayAid helps field teams report incidents with location and photo evidence when connectivity is unreliable, then coordinate a real team response through a live web command center. Built with Flutter and Serverpod 4 for **Build Something Real**.

[Cloud web host](https://relayaid.serverpod.space/) · [Source](https://github.com/nevil-ing/RelayAid) · [MIT license](LICENSE)

## The core flow

Sign in → turn connectivity off → report a flood with GPS and a photo → save locally → kill/reopen → restore connectivity → metadata synchronizes → photo uploads independently → coordinator sees it live → assigns Team Alpha → responder accepts, responds and resolves → full timeline remains.

This is a real local-first workflow, not a mocked sync indicator. Native SQLite and application-support files preserve reports and evidence; UUIDs make uncertain network retries safe. A report does not wait for its photos to upload.

## Release status

Target beta: **0.2.0 (2)**. Verification from a fresh committed checkout on 9 October 2026 passed **94 Flutter tests**, **74 Serverpod tests**, generation checks, formatting and both static analyzers. The matching backend and Flutter web app were deployed successfully to Cloud on 9 October; both additive migrations applied and the served web runtime matches the verified build. The signed iOS beta uploaded and processed successfully; the owner completed export compliance and the existing internal `testerr` group shows **Testing** for build 2. Previously distributed `0.1.0 (1)` does not include the full command-center, response, escalation or reporting polish.

Physical-device acceptance is scheduled for **10 October**. Automated SQLite/file reopen tests are not a substitute for the phone’s camera, GPS, kill/relaunch and Cloud/browser rehearsal. A genuine demo video will be linked after that rehearsal; no recording or competition submission is claimed yet.

## What works

- Three-step reporting: Incident → Location / evidence → Review. Foreground GPS is requested only on **Use current location**; permission/disabled/timeout states offer recovery or manual coordinates.
- Native offline reports and photos survive restarts. A visible Sync center explains pending, syncing, synchronized and retryable failed states.
- Organization-scoped web Overview, Incidents, Map and Activity receive Serverpod WebSocket snapshots without incident polling or manual refresh.
- Coordinators maintain responder rosters and assign teams, optionally designating an eligible responder. Workload counts represent active assignments, not invented online presence.
- A foreground responder inbox receives assignments live. Acceptance is first-claim-wins; the accepting responder starts responding and resolves with a required outcome note.
- Critical reports not acknowledged or assigned before their stored deadline receive automatic Serverpod Future Call escalation and an explicit scheduler-origin timeline event.
- Human actions, uploads and response transitions append immutable timeline events. Server-side membership, role, organization and roster checks protect operational boundaries.

## How Serverpod is used

```text
Flutter mobile + web
  ├── Native SQLite + local photo queue
  └── Generated typed Serverpod client
        ↓ HTTPS / WebSockets
      Serverpod modular monolith
        ├── Authentication + organization authorization
        ├── Incident / team / assignment services
        ├── Private uploads + live streams + Future Calls
        └── PostgreSQL + private file storage
              ↓
          Serverpod Cloud
```

| Serverpod capability | RelayAid use |
| --- | --- |
| Email authentication | Real sessions; roles remain server-held |
| Typed APIs / PostgreSQL | Incidents, memberships, teams, assignments and audit history |
| Streaming | Coordinator workspace and responder inbox with reconnect snapshots |
| File storage | Validated private photo uploads and authenticated reads |
| Future Calls | Persisted, recurring critical-incident escalation |
| Cloud | Existing hosted test backend and Flutter web host |

Offline synchronization is implemented by local repositories and explicit queues around typed APIs; it is **not** advertised as Serverpod’s client-database sync. Endpoints authenticate/delegate, services own rules, and widgets do not call incident networking or persistence APIs directly.

## Run locally

Verified toolchain: **Flutter 3.47.5 / Dart 3.13.4**, **Serverpod 4.0.1**. Put that Flutter SDK on PATH for all commands; keep client/server/CLI versions aligned. iOS builds also require Xcode and a valid signing account. Development/test configurations use embedded PostgreSQL; no Docker is needed for these tests.

```sh
git clone https://github.com/nevil-ing/RelayAid.git
cd RelayAid
flutter pub get
dart pub global activate serverpod_cli 4.0.1
```

Create `relayaid_server/config/passwords.yaml` locally using `passwords.yaml.example` as the shape. Replace every `CHANGE_ME` with a distinct cryptographically random value (for example, `openssl rand -hex 32`; use 64 bytes for the JWT HMAC key). Keep database/auth keys stable across local restarts. The real passwords file is ignored; never commit it.

```sh
cd relayaid_server
dart pub global run serverpod_cli:serverpod_cli generate
dart run bin/main.dart --apply-migrations
```

In another terminal:

```sh
cd relayaid_flutter
flutter run --dart-define=SERVER_URL=http://localhost:8080/
```

Use a reachable development host instead of `localhost` on a physical phone. Release builds reject insecure or loopback server addresses. Local email sign-up uses Serverpod’s development verification flow; Cloud email authentication must be checked separately with real accounts.

### Add members and Team Alpha

1. Administrator signs in and creates a dedicated test organization.
2. Each additional person signs up/signs in, then copies their **User ID** from Organization Setup or Profile. Use the actual authentication UUID, not an incident ID, team ID or invented value.
3. Administrator opens **Settings → Members**, enters that ID and chooses **Field worker**, **Responder** or **Coordinator**. New members tap **I have been added — check access**.
4. Coordinator opens **Teams**, creates **Team Alpha**, and adds the organization member with Responder role to its roster.
5. Keep coordinator Overview and responder Home open. Assign the synchronized incident, then accept → start responding → enter an outcome → resolve. Both clients update live.

Use three real accounts and separate browser sessions/devices for the rehearsal. Invitation links are not implemented. Do not bypass authentication or seed fake account UUIDs into Cloud.

## Verify

```sh
bash tool/verify.sh
# Also build the production web client:
bash tool/verify.sh --web
```

The script restores packages, generates/checks typed code, checks formatting and both analyzers, then runs both test suites. It creates process-only disposable test credentials; it does not alter Cloud or production configuration. Set `RELAYAID_FLUTTER_BIN=/absolute/path/to/flutter` when the verified SDK is not on PATH. Use a clean checkout because generated-code drift fails the check.

The backend rehearsal makes an actual HTTP report/upload, reads private bytes, receives WebSocket updates on coordinator/responder clients, completes the response and checks persisted incident/photo/timeline records. It uses isolated test-only authentication and disposable PostgreSQL data, not Cloud accounts.

```sh
cd relayaid_server
dart test test/integration/assignment_feed_test.dart \
  --plain-name 'demo rehearsal persists a UUID report, real photo and complete live response timeline'
```

Other checks cover organization isolation, invalid transitions, concurrent acceptance, real recurring scheduling, interrupted sync/upload recovery, duplicate retries, permission failure, startup retry, small-screen layouts and 200% text. Test map tiles/GPS/pickers are controlled fixtures; production uses real services. CI repeats generation, formatting, analysis, both suites and a release web build.

Read-only checks for HTTPS health, served Flutter runtime configuration and anonymous typed-API rejection:

```sh
cd relayaid_server
dart run tool/check_backend.dart
```

This smoke check never signs in, creates demo data or uploads evidence. Passing it does not prove successful real-account authentication or the complete phone/browser workflow.

## Deploy the matching beta

Existing Cloud project: `relayaid`. API: `https://relayaid.api.serverpod.space/`. Web: `https://relayaid.serverpod.space/`.

```sh
cd relayaid_flutter
flutter build web --release --base-href=/ --output=../relayaid_server/web/app \
  --dart-define=SERVER_URL=https://relayaid.api.serverpod.space/
cd ../relayaid_server
dart pub global run serverpod_cli:serverpod_cli cloud project show relayaid
dart pub global run serverpod_cli:serverpod_cli cloud deploy --wet-run --show-files
dart pub global run serverpod_cli:serverpod_cli cloud deploy
```

Cloud supplies database/host configuration, auth keys and private storage. `.scloudignore` excludes local environment YAML/passwords while including built `web/app/` output. Do not copy local credentials or rotate managed keys just to deploy. Verify HTTPS cookie authentication and the permitted web origin. Keep the beta at one API replica unless Redis-backed cross-replica messaging is configured and verified.

The release includes additive migrations `20261005182107801-assignment-workflow` and `20261007055002557-incident-escalation`. They add assignments/linked history and escalation timestamps without deleting incidents. Old typed clients may not understand new event values; update testers to the matching beta before rehearsing. Native SQLite migration 3 continues to own attachment queues; reporting polish requires no new schema.

```sh
cd relayaid_flutter
flutter build ipa --release --build-name=0.2.0 --build-number=2 \
  --dart-define=SERVER_URL=https://relayaid.api.serverpod.space/
```

Apple app ID: `6818691495`; bundle ID: `com.nevilingutu.relayaid`. Increment the build number per upload. `build/ios/archive/` and `build/ios/ipa/` are ignored. Archive success, upload, Apple processing, compliance and tester availability are separate checks; this is not a public App Store release.

## Offline, evidence and operational limits

- Durable offline creation is **native only**. Web unsent reports/photos are in memory and do not survive reload; the UI warns users to keep the tab open. Response actions are online-only; stale inbox snapshots are not durable offline assignments.
- Reports/photos upload only for the signed-in author. Metadata synchronizes before binary uploads. Transient photo retries back off from five seconds to five minutes; manual retry remains available.
- Up to five JPEG/PNG photos per incident, each at most 5 MB / 12 megapixels. The backend checks image bytes. Finalization publishes immutable canonical evidence plus one event. Organization members read via authenticated APIs, not permanent public URLs.
- Coordinator snapshots load up to 500 reports and 40 activity events, with outstanding escalations prioritized and visible truncation. Responder snapshots load 200 active and 50 recent terminal assignments. This is neither an unlimited archive search nor a high-volume delta feed.
- Foreground streaming is not OS background push. One assignment per incident; no reassignment UI, roster-removal UI, presence tracking, SMS or invitations.
- Escalation defaults to ten minutes from **server receipt**, not the offline phone’s creation time. `RELAYAID_ESCALATION_DELAY_SECONDS=10` is for a dedicated local demo only; it does not rewrite existing deadlines. Allow scheduler scan time; escalation is not automatic dispatch.
- Maps use best-effort public OpenStreetMap tiles with attribution, no offline prefetch and no SLA. Tile failures do not remove reports/coordinates. Configure permitted alternatives with public `MAP_TILE_URL`, `MAP_TILE_ATTRIBUTION`, `MAP_TILE_ATTRIBUTION_URL` defines; never embed private keys. See the [OSM tile policy](https://operations.osmfoundation.org/policies/tiles/).

RelayAid is a coordination tool, not an emergency-service dispatch guarantee. Use dedicated, consented demo data, not sensitive real incident records.

## Project structure

```text
RelayAid/
├── relayaid_client/                # generated typed client
├── relayaid_flutter/lib/
│   ├── app/                       # startup, router, responsive shells
│   ├── core/                      # network, storage, sync, location, errors
│   ├── design_system/             # tokens, theme, vector brand, components
│   ├── features/
│   │   ├── auth/ home/ reporting/ incidents/ media/
│   │   ├── assignments/ teams/ command_center/ map/
│   │   └── sync/ profile/
│   └── shared/                    # focused cross-feature presentation
├── relayaid_server/lib/src/
│   ├── endpoints/                 # auth/validation/delegation
│   ├── services/ authorization/   # business and access rules
│   ├── models/ generated/         # source + generated bindings
│   └── future_calls/              # escalation entry point
├── relayaid_server/migrations/
├── .github/workflows/             # format, analyze, tests + web compile
├── tool/verify.sh
├── LICENSE
└── README.md
```

Features use `domain/`, `data/`, `application/`, `presentation/` where justified, without empty layers. Riverpod owns state; go_router owns routing. Standard Serverpod boundaries remain intact. This README is the repository documentation; agent guides and internal planning/design notes stay outside the checkout.

## Remaining acceptance and roadmap

Before submission: update to the matching TestFlight beta, perform the phone/browser rehearsal twice, capture genuine screenshots and a video under three minutes, then attach verified links to the competition entry. Public source and MIT are authorized; current-source secret scanning is clean, but publication remains gated on approved cleanup of historical development credentials and internal guides. Do not expose the existing Git history before that cleanup.

Later, beyond the hackathon core: invitations, push notifications, reassignment, durable offline web storage and a production map provider. No competition outcome is guaranteed by passing tests.
