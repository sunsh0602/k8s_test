# 12. Operator / CRD

## 왜 중요한지

Kubernetes 확장 — CRD로 사용자 정의 리소스를 만들고, Operator(Controller)로 desired state를 유지하면 도메인 특화 오퍼레이션을 클러스터 네이티브하게 구현할 수 있음.

## 이 환경에서 (MacBook + VMware Fusion)

- **kubectl**: MacBook에서 실행(또는 master SSH). CRD 적용·CR 생성·조회는 일반 `kubectl apply/get`으로 가능.
- **Controller 개발**: MacBook에서 kubebuilder/operator-sdk로 프로젝트 생성 후, 바이너리를 클러스터 안에서 돌리거나 로컬에서 `KUBECONFIG`로 이 클러스터(192.168.137.10)를 바라보게 해 실행.
- **리소스**: Operator가 지나치게 많은 리소스를 쓰지 않도록 replica 1, 작은 request/limit으로 배포 권장.

## 목표

- Custom Resource Definition(CRD) 작성 및 적용
- Custom Resource(CR) 생성 및 조회
- Controller/Operator 패턴 이해 (kubebuilder, operator-sdk 등)

## 실습 순서 (예시)

1. CRD YAML 작성 후 `kubectl apply -f crd.yaml`. `kubectl get crd`로 등록 확인.
2. 해당 CR의 샘플 리소스 생성 후 `kubectl get <crd-plural>` 로 조회. (Controller 없어도 CR은 저장됨.)
3. 간단한 controller(예: kubebuilder 스캐폴드)로 CR 이벤트 감지 시 로그 출력 또는 부수 리소스 생성까지 구현 후 이 클러스터에 배포해 동작 확인.
