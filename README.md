# ababylove 🍼

**컴퓨터에 "이미 교육된 AI 아이"를 한 번에 깔아주는 스타터.**
비개발자(특히 처음 시작하는 분)를 위해, AI를 잘 쓰기 위한 기본 설정을 미리 다 해뒀습니다.

> AI는 생각보다 아부를 많이 합니다 — 틀려도 맞다고 하고, 근거 없이 추측하죠.
> ababylove는 그걸 막는 **검증 도구(Polyrus)** 와 **기본 교육(CLAUDE.md)** 을 함께 깔아줍니다.
> "돌 먹이려 해도 못 먹이게" 잡아주는 안전장치예요.

---

## 무엇이 깔리나요

- **기본 교육** (`CLAUDE.md`) — AI가 지켜야 할 기본기 9가지(추측 금지·먼저 읽기·끝까지 하기·아부 방지 등).
- **기본 도구 3종** (슬래시 명령)
  - `/기획안` — 복잡한 일은 먼저 계획을 세운다
  - `/실행` — 세운 계획대로 하나씩, 검수하며 진행한다
  - `/작업보고` — 한 일을 기록으로 남긴다
- **메모리 공책** — AI가 나를 기억하게 하는 빈 공책(HOT/USER).
- **권한 설정** — 흔한 작업은 매번 "허용할까요?"를 안 묻게 허용목록을 넣어, **AI가 자주 멈추지 않게** 합니다.
  (단, `rm -rf` 같은 위험한 명령은 안전망으로 계속 막습니다.)
- **검증 도구 Polyrus** — AI가 "됐다"고 해도 실제로 됐는지 자동 검사(설치 + 연결까지).

## 설치 — 두 가지 방법

### 방법 A. Claude Code에게 시키기 (가장 쉬움)
Claude Code(터미널)에 이렇게 한 줄만 붙여넣으세요:

> "이 깃헙 레포 설치해줘: `https://github.com/dlgur03-blip/ababylove`"

그러면 Claude Code가 이 README를 읽고 알아서 `install.sh`까지 실행합니다.

### 방법 B. 직접 명령어로

**Mac / Linux**
```bash
git clone https://github.com/dlgur03-blip/ababylove.git
cd ababylove
bash install.sh
```

**Windows** (PowerShell)
```powershell
git clone https://github.com/dlgur03-blip/ababylove.git
cd ababylove
powershell -ExecutionPolicy Bypass -File install.ps1
```

설치가 끝나면 Claude Code를 켜고 `/기획안` 부터 써보세요.

> Mac/Linux는 `install.sh`, Windows는 `install.ps1`. 되돌리기는 각각 `uninstall.sh` / `uninstall.ps1`.
> 방법 A(Claude Code에게 시키기)는 OS를 알아서 판단합니다.

## 안전 — 되돌리기

- 설치는 **항상 기존 설정을 먼저 백업**합니다(`~/.claude.bak.날짜`). 아무것도 잃지 않아요.
- 언제든 되돌리기: `bash uninstall.sh` (Windows는 `powershell -ExecutionPolicy Bypass -File uninstall.ps1`). Polyrus 떼어내고 백업으로 복원.
- 이미 잘 쓰게 됐다면 검증 도구만 떼도 됩니다: `polyrus unwrap claude`.

## 자주 묻는 것

- **인터넷·계정 필요한가요?** — Polyrus는 당신의 `claude` 로그인 그대로 씁니다(별도 API 키 불필요).
- **원래 쓰던 설정이 날아가나요?** — 설치 전 전부 백업합니다. 메모리 공책도 이미 있으면 안 덮어씁니다.
- **설치가 어려워요** — 강의의 "따라하기" 편을 보시거나, 방문/원격 설치를 요청하세요.

---

*검증 도구 Polyrus: https://github.com/dlgur03-blip/polyrus-v2*
*MIT 라이선스. 교육자료는 각 자료의 라이선스를 따릅니다.*
