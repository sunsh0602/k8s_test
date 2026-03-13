# 5. Observability

## 왜 중요한지

metrics / logs / tracing — 클러스터와 애플리케이션의 상태·성능·장애를 파악하려면 메트릭, 로그, 분산 트레이싱이 필요함.

## 이 환경에서 (MacBook + VMware Fusion)

- **VM 리소스**: Prometheus+Grafana+Alertmanager 등 한꺼번에 띄우면 메모리 부족할 수 있음. Helm 설치 시 replica·리소스 줄이기(`--set prometheus.prometheusSpec.resources.requests.memory=256Mi` 등).
- **접속**: Grafana/Jaeger UI는 LoadBalancer(MetalLB 192.168.137.x) 또는 NodePort로 노출 후 MacBook 브라우저에서 접속.
- **kubectl**: MacBook에서 실행하거나 master(192.168.137.10) SSH 후 실행.

## 목표

- Prometheus로 메트릭 수집
- Grafana 대시보드 및 Prometheus 연동
- (선택) Jaeger 등으로 분산 트레이싱
- 로그 수집 파이프라인(선택)

## 실습 순서 (예시)

1. **kube-prometheus-stack** Helm 설치 (Prometheus + Grafana + 기본 스크래핑).
2. 설치 시 Service 타입을 LoadBalancer로 두면 MetalLB가 IP 부여 → MacBook에서 Grafana 접속.
3. (선택) Jaeger Operator 또는 all-in-one 배포 후 동일하게 LoadBalancer/NodePort로 UI 노출.
4. 리소스 부족 시: `kubectl set resources` 또는 Helm values에서 메모리/CPU limit 낮추기.
