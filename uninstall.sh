#!/usr/bin/env bash
# ababylove 제거 — 설치 전 상태로 되돌립니다.
#   1) Polyrus 훅 연결 해제('졸업' — 검증 도구 떼어내기)
#   2) 설치 시 만든 백업으로 복원(현재 설정은 삭제하지 않고 옆에 보관)
set -uo pipefail

CLAUDE_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d_%H%M%S)"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  ✅ %s\n' "$*"; }
warn() { printf '  ⚠️  %s\n' "$*"; }

say ""
say "🧹 ababylove 제거를 시작합니다."

# ── 1) Polyrus 연결 해제 ─────────────────────────────────────────────────────
say "1) 검증 도구(Polyrus) 연결 해제"
if command -v polyrus >/dev/null 2>&1; then
  polyrus unwrap claude >/dev/null 2>&1 && ok "Polyrus 훅 제거" || warn "Polyrus 해제 실패(무시 가능)"
elif python3 -c "import polyrus" >/dev/null 2>&1; then
  python3 -m polyrus.cli unwrap claude >/dev/null 2>&1 && ok "Polyrus 훅 제거(모듈)" || true
else
  warn "polyrus 명령이 없어 건너뜁니다."
fi

# ── 2) 백업 복원 ─────────────────────────────────────────────────────────────
say "2) 설치 전 설정 복원"
# 가장 최근 백업 찾기
latest="$(ls -dt "$HOME"/.claude.bak.* 2>/dev/null | head -n1 || true)"
if [ -n "${latest:-}" ] && [ -d "$latest" ]; then
  if [ -d "$CLAUDE_DIR" ]; then
    mv "$CLAUDE_DIR" "$HOME/.claude.removed.$STAMP" 2>/dev/null \
      && ok "현재 설정을 옆에 보관 → $HOME/.claude.removed.$STAMP" \
      || warn "현재 설정 이동 실패"
  fi
  if cp -R "$latest" "$CLAUDE_DIR" 2>/dev/null; then
    ok "백업 복원 완료 ← $latest"
  else
    warn "복원 실패 — 수동 복원: cp -R $latest $CLAUDE_DIR"
  fi
else
  warn "복원할 백업(~/.claude.bak.*)을 찾지 못했습니다."
  warn "  Polyrus 훅만 해제되었습니다. CLAUDE.md/명령은 그대로 남아 있습니다."
fi

say ""
say "✅ 제거 완료. (보관된 현재 설정: $HOME/.claude.removed.$STAMP)"
say ""
