#!/usr/bin/env bash
# LGTM: Loki + Grafana + Tempo + Mimir, 동일 네임스페이스에서 상호 연동
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NS="${NS_MONITORING:-monitoring}"

helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update

kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo "==> 1/6 Mimir"
helm upgrade --install mimir grafana/mimir-distributed \
  --namespace "$NS" \
  -f "$ROOT/values/mimir.yaml" \
  --wait --timeout 20m

echo "==> 2/6 Loki (SingleBinary)"
helm upgrade --install loki grafana/loki \
  --namespace "$NS" \
  -f "$ROOT/values/loki.yaml" \
  --wait --timeout 15m

echo "==> 3/6 Tempo (OTLP 수신 + Mimir remote_write)"
helm upgrade --install tempo grafana/tempo \
  --namespace "$NS" \
  -f "$ROOT/values/tempo.yaml" \
  --wait --timeout 15m

echo "==> 4/6 Prometheus (스크랩 → Mimir remote_write)"
helm upgrade --install prom prometheus-community/prometheus \
  --namespace "$NS" \
  -f "$ROOT/values/prometheus.yaml" \
  --wait --timeout 15m

echo "==> 5/6 Promtail → Loki"
helm upgrade --install promtail grafana/promtail \
  --namespace "$NS" \
  -f "$ROOT/values/promtail.yaml" \
  --wait --timeout 10m

echo "==> 6/6 Grafana (데이터소스·트레이스-로그-메트릭 연동)"
helm upgrade --install grafana grafana/grafana \
  --namespace "$NS" \
  -f "$ROOT/values/grafana.yaml" \
  --wait --timeout 10m

echo ""
echo "설치 완료."
echo "  Grafana:    kubectl get svc -n $NS grafana"
echo "  Mimir 게이트웨이: kubectl get svc -n $NS mimir-gateway"
echo "  Tempo OTLP:  gRPC 4317 / HTTP 4318 (서비스 tempo)"
echo "로그인: admin / admin (values/grafana.yaml 에서 변경 가능)"
