#!/usr/bin/env bash
#
# Notifly SDK 검증 스크립트 (bash)
#
# Notifly SDK가 모바일 플랫폼에서 올바르게 설치/초기화되었는지 검증합니다:
# - iOS (CocoaPods / Swift Package Manager)
# - Android (Gradle + JitPack)
# - Flutter (pubspec.yaml)
# - React Native (package.json + 네이티브 설정 마커)
#
# 사용법:
#   bash scripts/validate-sdk.sh
#   bash scripts/validate-sdk.sh --check-install
#   bash scripts/validate-sdk.sh --check-init
#
# 종료 코드:
#   0 = 성공
#   1 = 검증 실패

set -euo pipefail

BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

log() {
  # shellcheck disable=SC2059 (printf 포맷 문자열은 의도적으로 사용)
  printf "%b\n" "$1"
}

die() {
  log "${RED}❌ $1${RESET}"
  exit 1
}

usage() {
  cat <<'USAGE'
Notifly SDK 검증 스크립트 (bash)

사용법:
  bash scripts/validate-sdk.sh [--check-install] [--check-init]

플래그를 주지 않으면 모든 검사를 수행합니다.

검사 항목:
  --check-install  Notifly SDK 의존성이 존재하는지 검증(iOS Podfile/Package.swift, Android build.gradle(.kts), Flutter pubspec.yaml, React Native package.json)
  --check-init     플랫폼별 엔트리포인트에서 초기화 마커를 탐색
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
  log "${BLUE}📦 iOS SDK 설치를 확인합니다...${RESET}"

  local found=0

  # CocoaPods
  local podfile="Podfile"
  [[ -f "ios/Podfile" ]] && podfile="ios/Podfile"
  if [[ -f "$podfile" ]]; then
    if grep -Eq "pod\\s+['\"]notifly_sdk['\"]" "$podfile" 2>/dev/null; then
      log "${GREEN}✓ ${podfile}에서 notifly_sdk를 찾았습니다${RESET}"
      found=1
    fi
  fi

  # Swift Package Manager
  if [[ -f "Package.swift" ]]; then
    if grep -Eq "team-michael/notifly-ios-sdk|github.com/team-michael/notifly-ios-sdk" Package.swift 2>/dev/null; then
      log "${GREEN}✓ Package.swift에서 notifly-ios-sdk를 찾았습니다${RESET}"
      found=1
    fi
  fi

  if [[ "$found" -eq 0 ]]; then
    log "${RED}✗ Notifly iOS SDK를 찾지 못했습니다(Podfile/Package.swift)${RESET}"
    log "${YELLOW}  iOS: 추가: pod 'notifly_sdk'  또는 SPM 추가: https://github.com/team-michael/notifly-ios-sdk${RESET}"
    return 1
  fi

  return 0
}

check_install_android() {
  log "${BLUE}📦 Android SDK 설치를 확인합니다...${RESET}"

  local found_dep=0
  local found_repo=0

  # 자주 사용하는 Gradle 파일들을 검색
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
    log "${GREEN}✓ Notifly Android SDK 의존성을 찾았습니다(com.github.team-michael:notifly-android-sdk)${RESET}"
  else
    log "${RED}✗ Notifly Android SDK 의존성을 찾지 못했습니다${RESET}"
    log "${YELLOW}  Android: 추가: implementation 'com.github.team-michael:notifly-android-sdk:<latest>'${RESET}"
    return 1
  fi

  if [[ "$found_repo" -eq 1 ]]; then
    log "${GREEN}✓ JitPack 저장소 설정을 찾았습니다${RESET}"
  else
    log "${YELLOW}⚠ JitPack 저장소 설정을 찾지 못했습니다(SDK를 resolve 하려면 필요)${RESET}"
    log "${YELLOW}  추가: maven { url 'https://jitpack.io' }${RESET}"
  fi

  return 0
}

check_install_flutter() {
  log "${BLUE}📦 Flutter SDK 설치를 확인합니다...${RESET}"

  if [[ ! -f "pubspec.yaml" ]]; then
    log "${RED}✗ pubspec.yaml을 찾지 못했습니다${RESET}"
    return 1
  fi

  if grep -Eq "^\\s*notifly_flutter:\\s*" pubspec.yaml 2>/dev/null; then
    log "${GREEN}✓ pubspec.yaml에서 notifly_flutter를 찾았습니다${RESET}"
    return 0
  fi

  log "${RED}✗ pubspec.yaml에서 notifly_flutter를 찾지 못했습니다${RESET}"
  log "${YELLOW}  Flutter: 실행: flutter pub add notifly_flutter${RESET}"
  return 1
}

check_install_react_native() {
  log "${BLUE}📦 React Native SDK 설치를 확인합니다...${RESET}"

  if [[ ! -f "package.json" ]]; then
    log "${RED}✗ package.json을 찾지 못했습니다${RESET}"
    return 1
  fi

  if grep -Eq "\"notifly-sdk\"" package.json 2>/dev/null; then
    log "${GREEN}✓ package.json에서 notifly-sdk를 찾았습니다${RESET}"
    return 0
  fi

  log "${RED}✗ package.json에서 notifly-sdk를 찾지 못했습니다${RESET}"
  log "${YELLOW}  React Native: 실행: npm install notifly-sdk@latest --save${RESET}"
  return 1
}

check_init_ios() {
  log "${BLUE}🔍 iOS 초기화 마커를 확인합니다...${RESET}"

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
    log "${GREEN}✓ AppDelegate에서 Notifly.initialize(...)를 찾았습니다${RESET}"
    return 0
  fi

  log "${YELLOW}⚠ 일반적인 AppDelegate 위치에서 Notifly.initialize(...)를 찾지 못했습니다${RESET}"
  return 1
}

check_init_android() {
  log "${BLUE}🔍 Android 초기화 마커를 확인합니다...${RESET}"

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
    log "${GREEN}✓ Android 소스에서 tech.notifly.Notifly.initialize(...)를 찾았습니다${RESET}"
    return 0
  fi

  log "${YELLOW}⚠ tech.notifly.Notifly.initialize(...)를 찾지 못했습니다${RESET}"
  return 1
}

check_init_flutter() {
  log "${BLUE}🔍 Flutter 초기화 마커를 확인합니다...${RESET}"

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
    log "${GREEN}✓ Dart 소스에서 NotiflyPlugin.initialize(...)를 찾았습니다${RESET}"
    return 0
  fi

  log "${YELLOW}⚠ NotiflyPlugin.initialize(...)를 찾지 못했습니다${RESET}"
  return 1
}

check_init_react_native() {
  log "${BLUE}🔍 React Native 초기화 마커를 확인합니다...${RESET}"

  local found_js=0
  if [[ -f "index.js" ]] || [[ -f "index.ts" ]] || [[ -f "index.tsx" ]] || [[ -f "App.tsx" ]]; then
    found_js=1
  fi

  # 네이티브 마커(iOS 브리지 헤더 import)
  local found_ios_native=0
  if find ios -maxdepth 4 -type f -name "AppDelegate.mm" 2>/dev/null | xargs -I{} grep -Eq "notifly_sdk-Swift\\.h" {} 2>/dev/null; then
    found_ios_native=1
  fi

  # 네이티브 마커(Android initialize)
  local found_android_native=0
  if find android -maxdepth 6 -type f \( -name "*.kt" -o -name "*.java" \) 2>/dev/null | xargs -I{} grep -Eq "tech\\.notifly\\.Notifly" {} 2>/dev/null; then
    found_android_native=1
  fi

  if [[ "$found_ios_native" -eq 1 ]]; then
    log "${GREEN}✓ iOS 네이티브 마커를 찾았습니다(notifly_sdk-Swift.h)${RESET}"
  else
    log "${YELLOW}⚠ iOS 네이티브 마커를 찾지 못했습니다(AppDelegate.mm 설정을 확인하세요)${RESET}"
  fi

  if [[ "$found_android_native" -eq 1 ]]; then
    log "${GREEN}✓ Android 네이티브 마커를 찾았습니다(tech.notifly.Notifly)${RESET}"
  else
    log "${YELLOW}⚠ Android 네이티브 마커를 찾지 못했습니다(Application 설정을 확인하세요)${RESET}"
  fi

  # 프로젝트 구조가 다양하므로 RN 초기화는 강제 실패 처리하지 않고, 가이드를 제공합니다.
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
        *) die "알 수 없는 인자: $arg" ;;
      esac
    done
  else
    check_install=1
    check_init=1
  fi

  local platform
  platform=$(detect_platform)

  if [[ "$platform" == "unknown" ]]; then
    die "플랫폼을 감지하지 못했습니다. 앱 프로젝트 루트(iOS/Android/Flutter/RN)에서 실행하세요."
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
    die "검증에 실패했습니다. 위의 경고 메시지를 확인하세요."
  fi

  log "${GREEN}✅ Notifly SDK 검증 통과 (플랫폼: ${platform})${RESET}"
}

main "$@"
