# ababylove 제거 (Windows / PowerShell)
#   1) Polyrus 훅 연결 해제
#   2) 설치 시 만든 백업으로 복원(현재 설정은 삭제하지 않고 옆에 보관)
# 실행:  powershell -ExecutionPolicy Bypass -File uninstall.ps1

$ErrorActionPreference = "Continue"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$Stamp     = Get-Date -Format "yyyyMMdd_HHmmss"

function Say($m)  { Write-Host $m }
function OK($m)   { Write-Host "  [OK] $m" }
function Warn($m) { Write-Host "  [!] $m" }

Say ""
Say "ababylove 제거를 시작합니다."

# ── 1) Polyrus 연결 해제 ─────────────────────────────────────────────────────
Say "1) 검증 도구(Polyrus) 연결 해제"
$Py = $null; $PyArgs = @()
foreach ($c in @("python","python3","py")) {
  if (Get-Command $c -ErrorAction SilentlyContinue) { $Py = $c; if ($c -eq "py") { $PyArgs = @("-3") }; break }
}
if (Get-Command polyrus -ErrorAction SilentlyContinue) {
  try { polyrus unwrap claude 2>$null; OK "Polyrus 훅 제거" } catch { Warn "해제 실패(무시 가능)" }
} elseif ($Py) {
  try { & $Py @PyArgs -m polyrus.cli unwrap claude 2>$null; OK "Polyrus 훅 제거(모듈)" } catch {}
} else {
  Warn "polyrus 명령이 없어 건너뜁니다."
}

# ── 2) 백업 복원 ─────────────────────────────────────────────────────────────
Say "2) 설치 전 설정 복원"
$latest = Get-ChildItem -Path $env:USERPROFILE -Directory -Filter ".claude.bak.*" -ErrorAction SilentlyContinue |
          Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latest) {
  if (Test-Path $ClaudeDir) {
    try { Move-Item $ClaudeDir (Join-Path $env:USERPROFILE ".claude.removed.$Stamp") -Force; OK "현재 설정을 옆에 보관 -> .claude.removed.$Stamp" }
    catch { Warn "현재 설정 이동 실패" }
  }
  try { Copy-Item $latest.FullName $ClaudeDir -Recurse -Force; OK "백업 복원 완료 <- $($latest.Name)" }
  catch { Warn "복원 실패 — 수동 복원 필요" }
} else {
  Warn "복원할 백업(.claude.bak.*)을 찾지 못했습니다. Polyrus 훅만 해제되었습니다."
}

Say ""
Say "제거 완료."
Say ""
