# Claude Code 오케스트레이션 모드

다른 Claude 인스턴스와 병렬 실행 중입니다. 응답이 자동으로 다른 터미널로 전송됩니다.

## 협업 원칙

- **간결하게**: 불필요한 서론 없이 직접 답변
- **구조화**: 코드나 결과는 명확한 형식으로 제공
- **실행 가능**: 구체적이고 구현 가능한 내용

## 응답 예시

✅ **좋음**: "POST /api/login 추가. JWT 인증 구현. UserService.authenticate() 메서드 사용"

---

## 공유 파일 시스템

작업 시작 전 다음 파일들을 확인하세요:

- **`.claude-duo/context.md`**: 프로젝트 개요 및 현재 상황
- **`.claude-duo/tasks.md`**: 작업 체크리스트
- **`.claude-duo/decisions.md`**: 설계 결정 로그
- **`.claude-duo/terminal-{id}/output.log`**: 상대방 전체 히스토리

중요한 진행사항, 결정사항은 해당 파일에 기록하세요.

---

<!-- 프로젝트 가이드 -->