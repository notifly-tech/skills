#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
if [[ "${ROOT}" == "--help" || "${ROOT}" == "-h" ]]; then
  cat <<'USAGE'
Usage: bash skills/integration/scripts/validate-web-sdk.sh [project-root]

Static checks for Notifly JavaScript SDK integration markers.
Run from the target web app root, or pass the app root path.
USAGE
  exit 0
fi

if [[ ! -d "$ROOT" ]]; then
  echo "❌ Project root not found: $ROOT"
  exit 1
fi

cd "$ROOT"

PASS=0
WARN=0
FAIL=0

ok() { echo "✅ $*"; PASS=$((PASS + 1)); }
warn() { echo "⚠️  $*"; WARN=$((WARN + 1)); }
fail() { echo "❌ $*"; FAIL=$((FAIL + 1)); }

file_exists() {
  [[ -f "$1" ]]
}

contains() {
  local pattern="$1"
  shift
  local files=("$@")
  if [[ ${#files[@]} -eq 0 ]]; then
    return 1
  fi
  grep -E -q -- "$pattern" "${files[@]}" 2>/dev/null
}

collect_files() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Include both tracked and untracked-but-not-ignored files so the validator
    # works immediately after adding integration files, before staging/commit.
    git ls-files --cached --others --exclude-standard -- \
      '*.js' '*.jsx' '*.ts' '*.tsx' '*.html' '*.vue' '*.svelte' '*.mjs' '*.cjs' \
      2>/dev/null || true
  else
    find . \
      -path './node_modules' -prune -o \
      -path './.next' -prune -o \
      -path './dist' -prune -o \
      -path './build' -prune -o \
      -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.html' -o -name '*.vue' -o -name '*.svelte' -o -name '*.mjs' -o -name '*.cjs' \) \
      -print
  fi
}

mapfile -t SOURCE_FILES < <(collect_files)

if file_exists package.json && grep -q '"notifly-js-sdk"' package.json; then
  ok "package.json contains notifly-js-sdk"
elif contains 'cdn\.jsdelivr\.net/npm/notifly-js-sdk|unpkg\.com/notifly-js-sdk' "${SOURCE_FILES[@]}"; then
  ok "Notifly JS SDK CDN script found"
else
  fail "No notifly-js-sdk dependency or CDN script found"
fi

if contains 'notifly\.initialize\s*\(' "${SOURCE_FILES[@]}"; then
  ok "notifly.initialize(...) call found"
else
  fail "notifly.initialize(...) call not found"
fi

if contains 'projectId\s*:' "${SOURCE_FILES[@]}" && contains 'username\s*:' "${SOURCE_FILES[@]}" && contains 'password\s*:' "${SOURCE_FILES[@]}"; then
  ok "initialize credentials markers found: projectId, username, password"
else
  fail "initialize credential markers missing: projectId, username, password"
fi

if contains 'pushSubscriptionOptions\s*:' "${SOURCE_FILES[@]}"; then
  warn "legacy pushSubscriptionOptions found; use only for SDK <= 2.4.x"
fi

if contains 'serviceWorkerPath\s*:' "${SOURCE_FILES[@]}"; then
  warn "serviceWorkerPath marker found in app code; for SDK 2.5+ verify this is legacy-only or console-configured"
fi

SW_CANDIDATES=(
  public/notifly-service-worker.js
  notifly-service-worker.js
  public/service-worker.js
  service-worker.js
  public/firebase-messaging-sw.js
  firebase-messaging-sw.js
  public/OneSignalSDKWorker.js
  OneSignalSDKWorker.js
)
FOUND_SW=()
for sw in "${SW_CANDIDATES[@]}"; do
  if file_exists "$sw"; then
    FOUND_SW+=("$sw")
  fi
done

if [[ ${#FOUND_SW[@]} -eq 0 ]]; then
  warn "No common Service Worker file found. This is OK for web-popup-only integration, but web push requires one."
else
  ok "Service Worker candidate(s): ${FOUND_SW[*]}"
  if contains 'NotiflyServiceWorker\.js' "${FOUND_SW[@]}"; then
    ok "Service Worker imports NotiflyServiceWorker.js"
  else
    warn "Service Worker candidate exists but NotiflyServiceWorker.js import was not found"
  fi
  if [[ ${#FOUND_SW[@]} -gt 1 ]]; then
    warn "Multiple Service Worker candidates found; verify scope/handler conflicts before enabling web push"
  fi
fi

if contains 'notifly\.requestPermission\s*\(' "${SOURCE_FILES[@]}"; then
  ok "manual notifly.requestPermission(...) call found"
  warn "manual permission prompt requires SDK 2.7.0+ and console auto prompt disabled"
else
  warn "manual notifly.requestPermission(...) not found; OK if console auto prompt is enabled or web push is not used"
fi

if contains 'notifly\.setUserId\s*\(' "${SOURCE_FILES[@]}"; then
  ok "notifly.setUserId(...) call found"
else
  warn "notifly.setUserId(...) not found; popup/push targeting may remain anonymous-device based"
fi

if contains 'notifly\.setUserProperties\s*\(' "${SOURCE_FILES[@]}"; then
  ok "notifly.setUserProperties(...) call found"
else
  warn "notifly.setUserProperties(...) not found"
fi

if contains 'notifly\.trackEvent\s*\(' "${SOURCE_FILES[@]}"; then
  ok "notifly.trackEvent(...) call found"
else
  warn "notifly.trackEvent(...) not found; event-triggered web popups will not fire"
fi

if contains "typeof[[:space:]]+window[[:space:]]*!==[[:space:]]*['\"]undefined['\"]|typeof[[:space:]]+window[[:space:]]*===[[:space:]]*['\"]undefined['\"]" "${SOURCE_FILES[@]}"; then
  ok "browser-only window guard found"
elif file_exists next.config.js || file_exists next.config.mjs || file_exists next.config.ts || grep -q '"next"' package.json 2>/dev/null; then
  warn "Next.js project detected but no typeof window guard found near static scan scope"
fi

echo
echo "Summary: ${PASS} passed, ${WARN} warning(s), ${FAIL} failure(s)"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
