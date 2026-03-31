# 5. Observability (LGTM)

Grafana Labs 스타일 **LGTM** 스택을 한 네임스페이스(`monitoring`)에 올리고, Grafana에서 **메트릭(Mimir)·로그(Loki)·트레이스(Tempo)** 가 서로 링크되도록 구성합니다.

| 문자 | 구성 요소 | 역할 |
|------|-----------|------|
| **L** | Loki + Promtail | 파드 로그 수집·저장 |
| **G** | Grafana | 통합 UI, Explore, 서비스 맵 |
| **T** | Tempo | 분산 트레이싱(OTLP), 스팬 메트릭 → Mimir |
| **M** | Mimir | Prometheus 호환 장기 메트릭 저장·쿼리 |

**추가**: `prometheus-community/prometheus` 차트로 클러스터/노드 메트릭을 스크랩한 뒤 **remote_write**로 Mimir에 넣습니다(로컬 Prometheus는 짧은 보존).

## 사전 조건

- MetalLB 등으로 외부 접근이 필요하면 Grafana `LoadBalancer`가 IP를 받을 수 있어야 합니다 (`values/grafana.yaml`).
- 스토리지: Mimir(MinIO)·Loki·Tempo·Prometheus·Grafana PVC — 클러스터에 기본 `StorageClass`가 있어야 합니다.

## 한 번에 정리 후 재설치

```bash
cd 05-observability
bash uninstall-legacy-monitoring.sh   # 기존 kube-prometheus / loki-stack / Jaeger 등 제거
bash install-lgtm.sh                  # LGTM + Prom + Promtail 설치
```

Helm 저장소가 없으면 스크립트가 `grafana`, `prometheus-community` repo를 추가합니다.

## 수동 설치(참고)

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring

helm install mimir grafana/mimir-distributed -n monitoring -f values/mimir.yaml
helm install loki grafana/loki -n monitoring -f values/loki.yaml
helm install tempo grafana/tempo -n monitoring -f values/tempo.yaml
helm install prom prometheus-community/prometheus -n monitoring -f values/prometheus.yaml
helm install promtail grafana/promtail -n monitoring -f values/promtail.yaml
helm install grafana grafana/grafana -n monitoring -f values/grafana.yaml
```

## 연동 동작

- **Grafana → Mimir**: PromQL(Explore·대시보드). Mimir 게이트웨이가 비어 있는 `X-Scope-OrgID`에 기본 테넌트를 채웁니다.
- **Grafana → Loki**: 로그 Explore. `derivedFields`로 로그의 trace id / UUID를 클릭하면 Tempo로 이동.
- **Grafana → Tempo**: 트레이스 Explore. **traces to logs** → Loki, **traces to metrics / service map** → Mimir(Prometheus 타입).
- **Promtail → Loki**: `values/promtail.yaml` 의 push URL.
- **Prometheus → Mimir**: `values/prometheus.yaml` 의 `remoteWrite`.
- **Tempo metrics-generator → Mimir**: 서비스 그래프·스팬 메트릭용 `remoteWriteUrl` (`values/tempo.yaml`).

애플리케이션은 **OTLP**로 Tempo에내면 됩니다(클러스터 내부 `tempo.monitoring.svc:4317` gRPC, `:4318` HTTP).

## 접속

```bash
kubectl get svc -n monitoring grafana
```

- 브라우저: `http://<EXTERNAL-IP>/` (LoadBalancer)
- 계정: `admin` / `admin` — `values/grafana.yaml` 의 `adminPassword` 로 변경.

## 값 파일

| 파일 | 설명 |
|------|------|
| `values/mimir.yaml` | classic 아키텍처(Kafka 끔), 단일 존·소형 리소스, 내장 MinIO |
| `values/loki.yaml` | SingleBinary, 파일시스템 스토리지 |
| `values/tempo.yaml` | 단일 레플리카, metrics generator → Mimir |
| `values/prometheus.yaml` | 스크랩 + Mimir remote_write, Alertmanager/Pushgateway 끔 |
| `values/promtail.yaml` | Loki push URL |
| `values/grafana.yaml` | 데이터소스 3종 + Tempo↔Loki↔Mimir jsonData |

**보안**: `values/mimir.yaml` 의 MinIO `rootPassword`, Grafana `adminPassword` 는 반드시 바꾸세요.

## LGTM만 제거

```bash
helm uninstall grafana prom promtail tempo loki mimir -n monitoring
kubectl delete pvc --all -n monitoring
```

## 트러블슈팅

- **PVC Pending**: StorageClass / OpenEBS 등 동적 프로비저닝 확인.
- **Mimir Pod이 뜨지 않음**: 노드 메모리 부족 시 `values/mimir.yaml` 에서 각 컴포넌트 `limits.memory` 를 더 낮춤.
- **Grafana에서 Mimir 쿼리 빈 결과**: `kubectl logs -n monitoring deploy/prom-prometheus-server` 로 remote_write 오류 확인, `mimir-gateway` 가 Ready 인지 확인.
- **서비스 맵이 비어 있음**: Tempo로 실제 트래픽이 들어오고 metrics-generator가 켜져 있어야 하며, Mimir에 스팬 메트릭이 remote write 되는지 확인.
