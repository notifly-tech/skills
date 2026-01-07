#!/usr/bin/env bash
#
# Notifly SDK Validation Script (bash)
#
# Validates that Notifly SDK is properly installed and initialized for mobile platforms:
# - iOS (CocoaPods / Swift Package Manager)
# - Android (Gradle + JitPack)
# - Flutter (pubspec.yaml)
# - React Native (package.json + native setup markers)
#
# Usage:
#   bash scripts/validate-sdk.sh
#   bash scripts/validate-sdk.sh --check-install
#   bash scripts/validate-sdk.sh --check-init
#
# Exit codes:
#   0 = success
#   1 = validation failed

set -euo pipefail

BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

log() {
  # shellcheck disable=SC2059
  printf "%b\n" "$1"
}

die() {
  log "${RED}❌ $1${RESET}"
  exit 1
}

usage() {
  cat <<'USAGE'
Notifly SDK Validation Script (bash)

Usage:
  bash scripts/validate-sdk.sh [--check-install] [--check-init]

If no flags are provided, all checks run.

Checks:
  --check-install  Validate Notifly SDK dependency is present (iOS Podfile/Package.swift, Android build.gradle(.kts), Flutter pubspec.yaml, React Native package.json)
  --check-init     Search platform-specific entrypoints for initialization markers
USAGE
}

detect_platform() {
  if [[ -f "Podfile" ]] || [[ -f "Package.swift" ]] || find . -maxdepth 3 \( -name "*.xcodeproj" -o -name "*.xcworkspace" \) 2>/dev/null | grep -q .; then
    echo "ios"
  elif [[ -f "build.gradle.kts" ]] || [[ -f "build.gradle" ]] || [[ -f "settings.gradle.kts" ]] || [[ -f "settings.gradle" ]] || [[ -d "app" && ( -f "app/build.gradle" || -f "app/build.gradle.kts" ) ]]; then
    echo "android"
  elif [[ -f "pubspec.yaml" ]]; then
    echo "flutter"
  elif [[ -f "package.json" ]] && (grep -q "react-native" package.json 2>/dev/null || ([[ -d "ios" ]] && [[ -d "android" ]])); then
    echo "react-native"
  else
    echo "unknown"
  fi
}

check_install_ios() {
  log "${BLUE}📦 Checking iOS SDK installation...${RESET}"

  local found=0

  # CocoaPods
  local podfile="Podfile"
  [[ -f "ios/Podfile" ]] && podfile="ios/Podfile"
  if [[ -f "$podfile" ]]; then
    if grep -Eq "pod\\s+['\"]notifly_sdk['\"]" "$podfile" 2>/dev/null; then
      log "${GREEN}✓ notifly_sdk found in ${podfile}${RESET}"
      found=1
    fi
  fi

  # Swift Package Manager
  if [[ -f "Package.swift" ]]; then
    if grep -Eq "team-michael/notifly-ios-sdk|github.com/team-michael/notifly-ios-sdk" Package.swift 2>/dev/null; then
      log "${GREEN}✓ notifly-ios-sdk found in Package.swift${RESET}"
      found=1
    fi
  fi

  if [[ "$found" -eq 0 ]]; then
    log "${RED}✗ Notifly iOS SDK not found (Podfile/Package.swift)${RESET}"
    log "${YELLOW}  iOS: Add: pod 'notifly_sdk'  OR add SPM: https://github.com/team-michael/notifly-ios-sdk${RESET}"
    return 1
  fi

  return 0
}

check_install_android() {
  log "${BLUE}📦 Checking Android SDK installation...${RESET}"

  local found_dep=0
  local found_repo=0

  # search common gradle files
  local files=(
    "build.gradle" "build.gradle.kts"
    "app/build.gradle" "app/build.gradle.kts"
    "settings.gradle" "settings.gradle.kts"
  )

  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue

    if grep -Eq "com.github.team-michael:notifly-android-sdk" "$f" 2>/dev/null; then
      found_dep=1
    fi

    if grep -Eq "jitpack\.io" "$f" 2>/dev/null; then
      found_repo=1
    fi
  done

  if [[ "$found_dep" -eq 1 ]]; then
    log "${GREEN}✓ Notifly Android SDK dependency found (com.github.team-michael:notifly-android-sdk)${RESET}"
  else
    log "${RED}✗ Notifly Android SDK dependency not found${RESET}"
    log "${YELLOW}  Android: Add: implementation 'com.github.team-michael:notifly-android-sdk:<latest>'${RESET}"
    return 1
  fi

  if [[ "$found_repo" -eq 1 ]]; then
    log "${GREEN}✓ JitPack repository found${RESET}"
  else
    log "${YELLOW}⚠ JitPack repository not detected (required to resolve the SDK)${RESET}"
    log "${YELLOW}  Add: maven { url 'https://jitpack.io' }${RESET}"
  fi

  return 0
}

check_install_flutter() {
  log "${BLUE}📦 Checking Flutter SDK installation...${RESET}"

  if [[ ! -f "pubspec.yaml" ]]; then
    log "${RED}✗ pubspec.yaml not found${RESET}"
    return 1
  fi

  if grep -Eq "^\\s*notifly_flutter:\\s*" pubspec.yaml 2>/dev/null; then
    log "${GREEN}✓ notifly_flutter found in pubspec.yaml${RESET}"
    return 0
  fi

  log "${RED}✗ notifly_flutter not found in pubspec.yaml${RESET}"
  log "${YELLOW}  Flutter: Run: flutter pub add notifly_flutter${RESET}"
  return 1
}

check_install_react_native() {
  log "${BLUE}📦 Checking React Native SDK installation...${RESET}"

  if [[ ! -f "package.json" ]]; then
    log "${RED}✗ package.json not found${RESET}"
    return 1
  fi

  if grep -Eq "\"notifly-sdk\"" package.json 2>/dev/null; then
    log "${GREEN}✓ notifly-sdk found in package.json${RESET}"
    return 0
  fi

  log "${RED}✗ notifly-sdk not found in package.json${RESET}"
  log "${YELLOW}  React Native: Run: npm install notifly-sdk@latest --save${RESET}"
  return 1
}

check_init_ios() {
  log "${BLUE}🔍 Checking iOS initialization markers...${RESET}"

  local files=(
    "AppDelegate.swift"
    "ios/AppDelegate.swift"
    "ios/Runner/AppDelegate.swift"
    "ios/Runner/AppDelegate.mm"
  )

  local found=0
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue
    if grep -Eq "Notifly\\.initialize\(" "$f" 2>/dev/null; then
      found=1
      break
    fi
  done

  if [[ "$found" -eq 1 ]]; then
    log "${GREEN}✓ Found Notifly.initialize(...) in AppDelegate${RESET}"
    return 0
  fi

  log "${YELLOW}⚠ Could not find Notifly.initialize(...) in common AppDelegate locations${RESET}"
  return 1
}

check_init_android() {
  log "${BLUE}🔍 Checking Android initialization markers...${RESET}"

  local found=0
  local candidates
  candidates=$(find . -maxdepth 6 -type f \( -name "*.kt" -o -name "*.java" \) 2>/dev/null || true)

  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    if grep -Eq "tech\\.notifly\\.Notifly" "$f" 2>/dev/null && grep -Eq "Notifly\\.initialize\(" "$f" 2>/dev/null; then
      found=1
      break
    fi
  done <<< "$candidates"

  if [[ "$found" -eq 1 ]]; then
    log "${GREEN}✓ Found tech.notifly.Notifly.initialize(...) in Android sources${RESET}"
    return 0
  fi

  log "${YELLOW}⚠ Could not find tech.notifly.Notifly.initialize(...)${RESET}"
  return 1
}

check_init_flutter() {
  log "${BLUE}🔍 Checking Flutter initialization markers...${RESET}"

  local found=0
  local candidates
  candidates=$(find . -maxdepth 6 -type f -name "*.dart" 2>/dev/null || true)

  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    if grep -Eq "NotiflyPlugin\\.initialize\(" "$f" 2>/dev/null; then
      found=1
      break
    fi
  done <<< "$candidates"

  if [[ "$found" -eq 1 ]]; then
    log "${GREEN}✓ Found NotiflyPlugin.initialize(...) in Dart sources${RESET}"
    return 0
  fi

  log "${YELLOW}⚠ Could not find NotiflyPlugin.initialize(...)${RESET}"
  return 1
}

check_init_react_native() {
  log "${BLUE}🔍 Checking React Native initialization markers...${RESET}"

  local found_js=0
  if [[ -f "index.js" ]] || [[ -f "index.ts" ]] || [[ -f "index.tsx" ]] || [[ -f "App.tsx" ]]; then
    found_js=1
  fi

  # Native markers (iOS bridge header import)
  local found_ios_native=0
  if find ios -maxdepth 4 -type f -name "AppDelegate.mm" 2>/dev/null | xargs -I{} grep -Eq "notifly_sdk-Swift\\.h" {} 2>/dev/null; then
    found_ios_native=1
  fi

  # Native markers (Android initialize)
  local found_android_native=0
  if find android -maxdepth 6 -type f \( -name "*.kt" -o -name "*.java" \) 2>/dev/null | xargs -I{} grep -Eq "tech\\.notifly\\.Notifly" {} 2>/dev/null; then
    found_android_native=1
  fi

  if [[ "$found_ios_native" -eq 1 ]]; then
    log "${GREEN}✓ Found iOS native marker (notifly_sdk-Swift.h)${RESET}"
  else
    log "${YELLOW}⚠ iOS native marker not found (check AppDelegate.mm setup)${RESET}"
  fi

  if [[ "$found_android_native" -eq 1 ]]; then
    log "${GREEN}✓ Found Android native marker (tech.notifly.Notifly)${RESET}"
  else
    log "${YELLOW}⚠ Android native marker not found (check Application setup)${RESET}"
  fi

  # We don't hard-fail RN init because projects vary, but we provide guidance.
  if [[ "$found_ios_native" -eq 1 || "$found_android_native" -eq 1 || "$found_js" -eq 1 ]]; then
    return 0
  fi

  return 1
}

main() {
  local check_install=0
  local check_init=0

  if [[ $# -gt 0 ]]; then
    for arg in "$@"; do
      case "$arg" in
        --check-install) check_install=1 ;;
        --check-init) check_init=1 ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown argument: $arg" ;;
      esac
    done
  else
    check_install=1
    check_init=1
  fi

  local platform
  platform=$(detect_platform)

  if [[ "$platform" == "unknown" ]]; then
    die "Could not detect platform. Run from your app project root (iOS/Android/Flutter/RN)."
  fi

  local ok=0

  if [[ "$check_install" -eq 1 ]]; then
    case "$platform" in
      ios) check_install_ios || ok=1 ;;
      android) check_install_android || ok=1 ;;
      flutter) check_install_flutter || ok=1 ;;
      react-native) check_install_react_native || ok=1 ;;
    esac
  fi

  if [[ "$check_init" -eq 1 ]]; then
    case "$platform" in
      ios) check_init_ios || ok=1 ;;
      android) check_init_android || ok=1 ;;
      flutter) check_init_flutter || ok=1 ;;
      react-native) check_init_react_native || ok=1 ;;
    esac
  fi

  if [[ "$ok" -ne 0 ]]; then
    die "Validation failed. See warnings above."
  fi

  log "${GREEN}✅ Notifly SDK validation passed for platform: ${platform}${RESET}"
}

main "$@"
