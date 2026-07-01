#!/usr/bin/env bash
# ababylove 설치 — "이미 교육된 아이"를 이 컴퓨터에 깔아줍니다.
#   1) 기존 설정 백업(되돌리기 보장)
#   2) 기본 교육(CLAUDE.md) + 도구(/기획안·/실행·/작업보고) + 메모리 공책 복사
#   3) 검증 도구 Polyrus 설치 + 연결('돌 먹이려 해도 못 먹이게')
# 안전 원칙: 무엇을 하기 전에 항상 백업. 중간에 실패해도 세션을 깨지 않음(안내 후 계속).
set -uo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # 이 스크립트가 있는 폴더
CLAUDE_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="$HOME/.claude.bak.$STAMP"
POLYRUS_URL="git+https://github.com/dlgur03-blip/polyrus-v2.git"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  ✅ %s\n' "$*"; }
warn() { printf '  ⚠️  %s\n' "$*"; }

say ""
say "🍼 ababylove 설치를 시작합니다."
say "   (설치 전 기존 설정은 자동 백업됩니다. 언제든 되돌릴 수 있어요.)"
say ""

# ── 1) 백업 ──────────────────────────────────────────────────────────────────
say "1) 기존 설정 백업"
if [ -d "$CLAUDE_DIR" ]; then
  if cp -R "$CLAUDE_DIR" "$BACKUP" 2>/dev/null; then
    ok "백업 완료 → $BACKUP"
  else
    warn "백업에 실패했지만 계속합니다. (수동 백업을 권장: cp -R $CLAUDE_DIR $BACKUP)"
  fi
else
  mkdir -p "$CLAUDE_DIR"
  ok "새 설정 폴더 생성 → $CLAUDE_DIR (기존 설정 없음)"
fi

# ── 2) 기본 교육 + 도구 + 공책 복사 ──────────────────────────────────────────
say ""
say "2) 기본 교육·도구·공책 설치"

# 2-1) CLAUDE.md (기본 교육)
if cp "$SRC/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
  ok "기본 교육(CLAUDE.md) 설치"
else
  warn "CLAUDE.md 복사 실패 — $SRC/claude/CLAUDE.md 를 확인하세요."
fi

# 2-2) 슬래시 명령 (/기획안 · /실행 · /작업보고)
mkdir -p "$CLAUDE_DIR/commands"
if cp "$SRC"/claude/commands/*.md "$CLAUDE_DIR/commands/" 2>/dev/null; then
  ok "도구 설치: /기획안 · /실행 · /작업보고"
else
  warn "명령 복사 실패 — $SRC/claude/commands/ 를 확인하세요."
fi

# 2-3) 스킬 폴더(있으면)
mkdir -p "$CLAUDE_DIR/skills"
cp -R "$SRC"/claude/skills/. "$CLAUDE_DIR/skills/" 2>/dev/null && ok "스킬 폴더 준비" || true

# 2-4) 메모리 공책 (이미 있으면 덮어쓰지 않음 — 내 기억 보호)
mkdir -p "$CLAUDE_DIR/memory"
for t in HOT USER MEMORY; do
  dst="$CLAUDE_DIR/memory/$t.md"
  src="$SRC/claude/memory/$t.md.template"
  if [ -f "$dst" ]; then
    ok "메모리 $t.md 는 이미 있어 그대로 둡니다(기억 보호)"
  elif [ -f "$src" ]; then
    cp "$src" "$dst" && ok "메모리 공책 생성: $t.md"
  fi
done

# ── 3) Polyrus 검증 도구 설치 + 연결 ─────────────────────────────────────────
say ""
say "3) 검증 도구(Polyrus) 설치 — '돌 먹이기' 방지"

if ! command -v python3 >/dev/null 2>&1; then
  warn "python3 가 없어 Polyrus 설치를 건너뜁니다."
  warn "  (python3 설치 후 다시 실행하면 검증 도구가 붙습니다: https://www.python.org/downloads/)"
else
  installed=0
  if command -v pipx >/dev/null 2>&1; then
    pipx install "$POLYRUS_URL" >/dev/null 2>&1 && installed=1
  fi
  if [ "$installed" -eq 0 ]; then
    python3 -m pip install --user "$POLYRUS_URL" >/dev/null 2>&1 && installed=1
  fi
  if [ "$installed" -eq 0 ]; then
    python3 -m pip install --user --break-system-packages "$POLYRUS_URL" >/dev/null 2>&1 && installed=1
  fi
  if [ "$installed" -eq 1 ]; then
    ok "Polyrus 설치 완료"
  else
    warn "Polyrus 설치 실패 — 인터넷/파이썬 환경을 확인하세요. (나머지는 정상 설치됨)"
  fi

  # 연결(두 훅 등록). 콘솔 스크립트가 PATH에 없을 수 있어 모듈로도 시도.
  if command -v polyrus >/dev/null 2>&1; then
    polyrus connect >/dev/null 2>&1 && ok "Polyrus 연결(완료검증 + 이해검증 훅)" \
      || warn "Polyrus 연결 실패 — 나중에 'polyrus connect' 를 실행하세요."
  elif python3 -c "import polyrus" >/dev/null 2>&1; then
    python3 -m polyrus.cli connect >/dev/null 2>&1 && ok "Polyrus 연결(모듈 경로)" \
      || warn "Polyrus 연결 실패 — 나중에 'python3 -m polyrus.cli connect' 를 실행하세요."
  else
    warn "polyrus 명령을 찾지 못했습니다. PATH 설정 후 'polyrus connect' 를 실행하세요."
  fi
fi

# ── 마무리 ───────────────────────────────────────────────────────────────────
say ""
say "🎉 설치가 끝났습니다!"
say "   • Claude Code를 켜고, 복잡한 일은 '/기획안' 으로 시작해 보세요."
say "   • '/실행' 으로 계획대로 진행하고, '/작업보고' 로 기록을 남깁니다."
say "   • AI가 '됐다'고 해도 Polyrus가 실제로 됐는지 자동 검사합니다."
say ""
say "   되돌리고 싶으면: bash \"$SRC/uninstall.sh\""
say "   (백업 위치: $BACKUP)"
say ""
