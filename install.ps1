# ababylove 설치 (Windows / PowerShell)
#   1) 기존 설정 백업(되돌리기 보장)
#   2) 기본 교육(CLAUDE.md) + 도구(/기획안·/실행·/작업보고) + 메모리 공책 + 권한 허용목록
#   3) 검증 도구 Polyrus 설치 + 연결
# 실행:  powershell -ExecutionPolicy Bypass -File install.ps1
# 안전: 무엇을 하기 전에 항상 백업. 중간 실패해도 세션을 깨지 않음(안내 후 계속).

$ErrorActionPreference = "Continue"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$Src       = $PSScriptRoot
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$Stamp     = Get-Date -Format "yyyyMMdd_HHmmss"
$Backup    = Join-Path $env:USERPROFILE ".claude.bak.$Stamp"
$PolyrusUrl= "git+https://github.com/dlgur03-blip/polyrus-v2.git"

function Say($m)  { Write-Host $m }
function OK($m)   { Write-Host "  [OK] $m" }
function Warn($m) { Write-Host "  [!] $m" }

Say ""
Say "ababylove 설치를 시작합니다. (설치 전 기존 설정은 자동 백업됩니다.)"
Say ""

# ── 1) 백업 ──────────────────────────────────────────────────────────────────
Say "1) 기존 설정 백업"
if (Test-Path $ClaudeDir) {
  try { Copy-Item $ClaudeDir $Backup -Recurse -Force -ErrorAction Stop; OK "백업 완료 -> $Backup" }
  catch { Warn "백업 실패했지만 계속합니다." }
} else {
  New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
  OK "새 설정 폴더 생성 -> $ClaudeDir (기존 설정 없음)"
}

# ── 2) 기본 교육 + 도구 + 공책 복사 ──────────────────────────────────────────
Say ""
Say "2) 기본 교육·도구·공책 설치"

# 2-1) CLAUDE.md
try { Copy-Item (Join-Path $Src "claude\CLAUDE.md") (Join-Path $ClaudeDir "CLAUDE.md") -Force -ErrorAction Stop; OK "기본 교육(CLAUDE.md) 설치" }
catch { Warn "CLAUDE.md 복사 실패" }

# 2-2) 슬래시 명령
$cmdDir = Join-Path $ClaudeDir "commands"
New-Item -ItemType Directory -Force -Path $cmdDir | Out-Null
try { Copy-Item (Join-Path $Src "claude\commands\*.md") $cmdDir -Force -ErrorAction Stop; OK "도구 설치: /기획안 · /실행 · /작업보고" }
catch { Warn "명령 복사 실패" }

# 2-3) 스킬 폴더
$skDir = Join-Path $ClaudeDir "skills"
New-Item -ItemType Directory -Force -Path $skDir | Out-Null
try { Copy-Item (Join-Path $Src "claude\skills\*") $skDir -Recurse -Force -ErrorAction SilentlyContinue; OK "스킬 폴더 준비" } catch {}

# 2-4) 메모리 공책 (이미 있으면 안 덮어씀)
$memDir = Join-Path $ClaudeDir "memory"
New-Item -ItemType Directory -Force -Path $memDir | Out-Null
foreach ($t in @("HOT","USER","MEMORY")) {
  $dst = Join-Path $memDir "$t.md"
  $srcT = Join-Path $Src "claude\memory\$t.md.template"
  if (Test-Path $dst) { OK "메모리 $t.md 는 이미 있어 그대로 둡니다(기억 보호)" }
  elseif (Test-Path $srcT) { Copy-Item $srcT $dst -Force; OK "메모리 공책 생성: $t.md" }
}

# ── 파이썬 탐지 (권한 병합·Polyrus에 필요) ────────────────────────────────────
$Py = $null; $PyArgs = @()
foreach ($c in @("python","python3","py")) {
  if (Get-Command $c -ErrorAction SilentlyContinue) {
    $Py = $c; if ($c -eq "py") { $PyArgs = @("-3") }; break
  }
}

# 2-5) 권한 허용목록 병합 (자주 멈추지 않게)
$permFile = Join-Path $Src "claude\permissions.json"
if ($Py -and (Test-Path $permFile)) {
  $env:ABABY_SETTINGS = Join-Path $ClaudeDir "settings.json"
  $env:ABABY_PERMS = $permFile
  $merge = @'
import json, os
sp = os.environ["ABABY_SETTINGS"]
cur = {}
if os.path.exists(sp):
    try:
        with open(sp, encoding="utf-8") as f: cur = json.load(f)
    except Exception: cur = {}
add = json.load(open(os.environ["ABABY_PERMS"], encoding="utf-8")).get("permissions", {})
perm = cur.setdefault("permissions", {})
for key in ("allow", "deny"):
    ex = perm.setdefault(key, [])
    for it in add.get(key, []):
        if it not in ex: ex.append(it)
os.makedirs(os.path.dirname(sp), exist_ok=True)
with open(sp, "w", encoding="utf-8") as f: json.dump(cur, f, ensure_ascii=False, indent=2)
'@
  try { $merge | & $Py @PyArgs -; OK "권한 허용목록 병합(자주 멈추지 않게)" }
  catch { Warn "권한 병합 실패 — 나중에 설정에서 허용목록을 추가하세요." }
} else {
  Warn "파이썬 없음 또는 permissions.json 없음 — 권한 병합 건너뜀"
}

# ── 3) Polyrus 설치 + 연결 ───────────────────────────────────────────────────
Say ""
Say "3) 검증 도구(Polyrus) 설치 — '돌 먹이기' 방지"
if (-not $Py) {
  Warn "파이썬이 없어 Polyrus 설치를 건너뜁니다. (https://www.python.org/downloads/ 설치 후 다시 실행)"
} else {
  $installed = $false
  try { & $Py @PyArgs -m pip install --user $PolyrusUrl 2>$null; if ($LASTEXITCODE -eq 0) { $installed = $true } } catch {}
  if ($installed) { OK "Polyrus 설치 완료" } else { Warn "Polyrus 설치 실패 — 인터넷/파이썬 환경 확인(나머지는 정상)" }

  if (Get-Command polyrus -ErrorAction SilentlyContinue) {
    try { polyrus connect 2>$null; OK "Polyrus 연결(완료검증 + 이해검증 훅)" } catch { Warn "연결 실패 — 나중에 'polyrus connect'" }
  } else {
    try { & $Py @PyArgs -m polyrus.cli connect 2>$null; OK "Polyrus 연결(모듈 경로)" }
    catch { Warn "polyrus 명령을 못 찾음 — 나중에 'polyrus connect' 실행" }
  }
}

# ── 마무리 ───────────────────────────────────────────────────────────────────
Say ""
Say "설치가 끝났습니다!"
Say "  • Claude Code를 켜고 복잡한 일은 '/기획안' 으로 시작하세요."
Say "  • '/실행' 으로 진행하고 '/작업보고' 로 기록을 남깁니다."
Say "  • AI가 '됐다'고 해도 Polyrus가 실제로 됐는지 자동 검사합니다."
Say ""
Say "  되돌리기: powershell -ExecutionPolicy Bypass -File `"$Src\uninstall.ps1`""
Say "  (백업 위치: $Backup)"
Say ""
