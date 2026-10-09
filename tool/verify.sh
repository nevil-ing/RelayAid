#!/usr/bin/env bash
set -euo pipefail

task_repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$task_repo_root"

if [[ -n "${RELAYAID_FLUTTER_BIN:-}" ]]; then
  task_flutter="$RELAYAID_FLUTTER_BIN"
elif [[ -x "$task_repo_root/.tooling/flutter/bin/flutter" ]]; then
  task_flutter="$task_repo_root/.tooling/flutter/bin/flutter"
else
  task_flutter="$(command -v flutter)"
fi
task_dart="$(dirname "$task_flutter")/dart"
export PATH="$(dirname "$task_flutter"):$PATH"

"$task_flutter" --version
"$task_flutter" pub get
(cd relayaid_server && "$task_dart" pub global run serverpod_cli:serverpod_cli generate)
git diff --exit-code -- relayaid_client/lib relayaid_server/lib/src/generated relayaid_server/test/integration/test_tools
"$task_dart" format --output=none --set-exit-if-changed relayaid_client relayaid_server relayaid_flutter
"$task_dart" analyze relayaid_client --fatal-infos
"$task_dart" analyze relayaid_server --fatal-infos
(cd relayaid_flutter && "$task_flutter" analyze --no-pub --fatal-infos)

# Only this verification process receives these disposable test credentials.
# No passwords file, production database, or Cloud configuration is changed.
export SERVERPOD_PASSWORD_database="$(openssl rand -hex 24)"
export SERVERPOD_PASSWORD_emailSecretHashPepper="$(openssl rand -hex 32)"
export SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey="$(openssl rand -hex 64)"
export SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper="$(openssl rand -hex 32)"
(cd relayaid_flutter && "$task_flutter" test --no-pub)
(cd relayaid_server && "$task_dart" test)

if [[ "${1:-}" == "--web" ]]; then
  (cd relayaid_flutter && "$task_flutter" build web --release --no-pub \
    --dart-define=SERVER_URL=https://relayaid.api.serverpod.space/)
fi
