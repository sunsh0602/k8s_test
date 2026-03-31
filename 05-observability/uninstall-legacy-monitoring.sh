#!/usr/bin/env bash
# 기존 kube-prometheus / 중복 Grafana / Loki-stack / Jaeger(tracing) 등 관측 스택 정리
set -euo pipefail

NS_MONITORING="${NS_MONITORING:-monitoring}"

echo "==> Helm release 제거 (monitoring 네임스페이스)"
for rel in grafana prom promtail tempo loki mimir kube-prometheus-stack; do
  if helm status "$rel" -n "$NS_MONITORING" &>/dev/null; then
    helm uninstall "$rel" -n "$NS_MONITORING"
  fi
done || true

echo "==> Helm: loki-stack (loki-stack 네임스페이스)"
if helm status loki-stack -n loki-stack &>/dev/null; then
  helm uninstall loki-stack -n loki-stack
fi || true

echo "==> 네임스페이스 loki-stack / tracing 삭제 (--wait=false, Terminating 은 백그라운드에서 정리)"
kubectl delete namespace loki-stack tracing --ignore-not-found --wait=false 2>/dev/null || true

echo "==> Prometheus Operator 리소스·남은 워크로드 정리 ($NS_MONITORING)"
kubectl delete deployment grafana -n "$NS_MONITORING" --ignore-not-found --wait=true
kubectl delete deployment prometheus-operator -n "$NS_MONITORING" --ignore-not-found --wait=true
kubectl delete statefulset prometheus-k8s -n "$NS_MONITORING" --ignore-not-found --wait=true

kubectl delete prometheus,alertmanager,prometheusagent --all -n "$NS_MONITORING" --ignore-not-found --wait=true 2>/dev/null || true
kubectl delete servicemonitor,podmonitor,probe --all -n "$NS_MONITORING" --ignore-not-found --wait=true 2>/dev/null || true
kubectl delete prometheusrule --all -n "$NS_MONITORING" --ignore-not-found --wait=true 2>/dev/null || true

echo "==> monitoring 네임스페이스 PVC·네임스페이스 삭제"
kubectl delete pvc --all -n "$NS_MONITORING" --ignore-not-found --wait=true 2>/dev/null || true
kubectl delete namespace "$NS_MONITORING" --ignore-not-found --wait=false 2>/dev/null || true
for _ in $(seq 1 90); do
  kubectl get ns "$NS_MONITORING" &>/dev/null || break
  sleep 2
done

echo "완료. 이후 install-lgtm.sh 로 새 스택을 설치하세요."
