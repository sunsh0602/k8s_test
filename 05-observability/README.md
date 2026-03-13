# 5. Observability

## 왜 중요한지

metrics / logs / tracing — 클러스터와 애플리케이션의 상태·성능·장애를 파악하려면 메트릭, 로그, 분산 트레이싱이 필요함.

## 이 환경에서 (MacBook + VMware Fusion)

- **사전 조건**: 3단계 MetalLB 설치 및 주소 풀(192.168.137.100~120) 설정 완료.
- **접속**: Grafana/Jaeger UI는 LoadBalancer(MetalLB)로 노출 → MacBook에서 `http://192.168.137.1xx` 접속.
- **리소스**: VM 메모리 절약을 위해 `values-monitoring.yaml`에서 요청/한도 축소. 부족하면 replica·retention 추가 조정.

---

## 1. Prometheus + Grafana (kube-prometheus-stack)

### 1-1. Helm repo 추가 및 네임스페이스

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
```

### 1-2. kube-prometheus-stack 설치

이 디렉토리에서 실행 (상위 k8s-local 루트에서면 `-f 05-observability/values-monitoring.yaml` 사용).

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f values-monitoring.yaml
```

- `values-monitoring.yaml`: Grafana LoadBalancer, Prometheus/Alertmanager 등 리소스 절감.

### 1-3. Pod 기동 대기

```bash
kubectl get pods -n monitoring -w
# Running 이 될 때까지 대기 (Ctrl+C로 종료)
```

또는 타임아웃으로 대기:

```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
```

### 1-4. Grafana 접속 주소 확인

```bash
kubectl get svc -n monitoring -l app.kubernetes.io/name=grafana
```

- `TYPE` 이 `LoadBalancer` 이고 `EXTERNAL-IP` 에 192.168.137.1xx 가 할당되면 MacBook 브라우저에서 접속 가능.

### 1-5. Grafana 로그인

- **URL**: `http://<EXTERNAL-IP>/` (예: http://192.168.137.101/)
- **계정**: `admin`
- **비밀번호**: `values-monitoring.yaml` 에 설정한 값 (`admin`). 변경했으면 해당 값 사용.

비밀번호를 시크릿에서 확인하려면:

```bash
kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d
echo
```

### 1-6. Prometheus 데이터소스 확인

- Grafana 로그인 후 **Connections** → **Data sources** 에서 `Prometheus` 가 이미 등록되어 있음.
- **Explore** 에서 PromQL 예: `up`, `node_memory_MemAvailable_bytes` 등으로 메트릭 확인.

### 1-7. (선택) Prometheus UI 직접 접속

Prometheus는 기본이 ClusterIP. 포트포워드로 접속:

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# MacBook 브라우저: http://localhost:9090
```

---

## 2. Jaeger (분산 트레이싱, 선택)

### 2-1. Jaeger all-in-one 배포

```bash
kubectl create namespace tracing
kubectl apply -f jaeger-all-in-one.yaml
```

- `jaeger-all-in-one.yaml`: all-in-one 디플로이먼트 + LoadBalancer 서비스 (이 디렉토리에 있음).

### 2-2. Jaeger UI 접속

```bash
kubectl get svc -n tracing
```

- `jaeger-all-in-one` 서비스의 `EXTERNAL-IP` (MetalLB)로 MacBook에서 접속.
- **URL**: `http://<EXTERNAL-IP>:16686` (Jaeger UI)

### 2-3. 정리

```bash
kubectl delete namespace tracing
```

---

## 3. 정리 (전체 제거)

### Prometheus + Grafana 스택 제거

```bash
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring
```

### (선택) PVC까지 삭제

```bash
kubectl delete pvc -n monitoring -l app.kubernetes.io/name=prometheus
```

---

## 매니페스트 요약

| 파일 | 용도 |
|------|------|
| `values-monitoring.yaml` | kube-prometheus-stack Helm values (Grafana LB, 리소스 절감) |
| `jaeger-all-in-one.yaml` | Jaeger all-in-one + LoadBalancer (선택) |

---

## 트러블슈팅

- **Grafana External-IP가 pending**: MetalLB 미설치 또는 주소 풀 소진. 3단계 MetalLB 확인.
- **Pod가 ImagePullBackOff**: 노드에서 외부 레지스트리 접근 가능한지 확인. 필요 시 이미지 풀 시크릿 설정.
- **메모리 부족**: `values-monitoring.yaml` 에서 `prometheus.prometheusSpec.resources.limits.memory` 더 낮추거나, `retention` 을 1d 로 줄이기.
