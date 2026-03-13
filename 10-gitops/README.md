# 10. GitOps

## 왜 중요한지

CI/CD 자동화 — Git을 단일 소스로 두고, 클러스터 상태를 선언적으로 맞추면 배포·롤백·감사가 일관되고 자동화됨.

## 이 환경에서 (MacBook + VMware Fusion)

- **Argo CD / Flux**: MacBook에서 Helm 또는 manifest로 클러스터에 설치. UI 접속은 LoadBalancer(MetalLB) 또는 port-forward(`kubectl port-forward svc/argocd-server -n argocd 8080:443`).
- **Git 저장소**: 본인 GitHub/GitLab 또는 로컬 Git 저장소(k8s-local 내 디렉토리도 path 또는 file URL로 지정 가능). 프라이빗 레포면 인증 설정 필요.
- **대상 클러스터**: 동일 클러스터(master 192.168.137.10)를 in-cluster로 사용. kubeconfig는 이미 설정된 상태 가정.

## 목표

- GitOps 개념(Argo CD, Flux 등) 이해
- Git 저장소와 클러스터 동기화
- 애플리케이션 배포/업데이트를 Git push로 반영

## 실습 순서 (예시)

1. Argo CD Helm 설치 후 Service를 LoadBalancer로 두면 MetalLB IP로 UI 접속. 초기 admin 비밀번호는 시크릿에서 조회.
2. Argo CD에서 Git 저장소(또는 로컬 manifest 경로) 등록 후 Application 생성.
3. Git에서 YAML 수정 후 push → Argo CD가 동기화해 배포 반영되는지 확인.
