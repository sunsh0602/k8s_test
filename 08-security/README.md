# 8. Security

## 왜 중요한지

RBAC / NetworkPolicy — 누가 무엇에 접근할 수 있는지(RBAC), 어떤 트래픽을 허용/차단할지(NetworkPolicy)로 클러스터와 파드 보안을 강화함.

## 이 환경에서 (MacBook + VMware Fusion)

- **kubectl**: MacBook 또는 master(192.168.137.10)에서 실행. RBAC 실습 시 별도 ServiceAccount로 `kubectl auth can-i` 검증.
- **NetworkPolicy**: CNI가 NetworkPolicy를 지원해야 함(Calico, Cilium 등). 이 환경의 Pod CIDR은 172.20.0.0/16.
- **실습**: default 네임스페이스에 테스트용 Pod/Service 띄운 뒤 NetworkPolicy 적용해 트래픽 차단/허용 확인.

## 목표

- ServiceAccount, Role, RoleBinding, ClusterRole 이해
- RBAC으로 API 접근 제한 설정
- NetworkPolicy로 Pod 간/외부 트래픽 제어

## 실습 순서 (예시)

1. Role, RoleBinding YAML 작성 후 적용 → 해당 ServiceAccount로 Pod 실행해 API 접근 가능/불가 검증.
2. NetworkPolicy YAML 작성(selector, ingress/egress) 후 적용 → 다른 Pod에서 curl 등으로 접근 차단 여부 확인.
