# 4. Ingress Controller

## 왜 중요한지

L7 routing — 하나의 진입점에서 호스트/경로별로 서비스를 라우팅. HTTP(S) 트래픽을 서비스별로 나누는 표준 방식.

## 이 환경에서 (MacBook + VMware Fusion)

- **사전 조건**: 3단계 MetalLB 설치 및 주소 풀(192.168.137.100~120) 설정 완료 권장.
- Ingress Controller를 LoadBalancer로 두면 MetalLB가 External IP 부여 → MacBook에서 `http://<EXTERNAL-IP>` 로 접속.
- NodePort만 쓸 경우: `http://192.168.137.10:3xxxx` (ingress-nginx의 NodePort 확인).

## 목표

- Ingress Controller(Ingress Nginx) 설치
- Host/Path 기반 Ingress 리소스 정의
- MetalLB 또는 NodePort로 Controller 노출 후 접근 검증

## 실습 순서

### 1) Ingress Nginx Controller 설치 (Helm)

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --set controller.service.type=LoadBalancer
# MetalLB가 자동으로 EXTERNAL-IP 할당 (예: 192.168.137.101)
kubectl get svc -n default -l app.kubernetes.io/name=ingress-nginx
```

### 2) 테스트용 앱 + Ingress

**Path 기반** 실습:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f ingress-path.yaml
```

**Host 기반** 실습 (app.local):
```bash
kubectl apply -f deployment.yaml
kubectl apply -f ingress-host.yaml
```

### 3) MacBook에서 접속

- Ingress Controller의 External IP 확인: `kubectl get svc` (예: 192.168.137.101)

- **Path 기반** (`ingress-path.yaml`): DNS/hosts 설정 없이 접속
  - `http://<EXTERNAL-IP>/foo` → foo 서비스
  - `http://<EXTERNAL-IP>/bar` → bar 서비스

- **Host 기반** (`ingress-host.yaml`): MacBook에서 `/etc/hosts`에 추가 후 접속
  - `192.168.137.101 app.local` (EXTERNAL-IP는 실제 값으로 변경)
  - 브라우저: `http://app.local/` → foo 서비스

### 4) 정리

```bash
kubectl delete -f ingress-path.yaml -f deployment.yaml
# 또는 Host 기반 사용 시: kubectl delete -f ingress-host.yaml -f deployment.yaml
helm uninstall ingress-nginx
```

## 매니페스트

- `deployment.yaml` — Ingress에서 라우팅할 테스트 Deployment/Service (foo, bar)
- `ingress-path.yaml` — Path 기반 라우팅 (/foo → foo, /bar → bar)
- `ingress-host.yaml` — Host 기반 라우팅 (app.local → foo)
