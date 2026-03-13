# 1. Kubernetes 기본

## 왜 중요한지

Pod / Service / Deployment / DNS — 워크로드와 서비스 발견의 기초. 이후 모든 단계의 토대가 됨.

## 이 환경에서 (MacBook + VMware Fusion)

- **노드 IP**: 192.168.137.10(master), .11(worker1), .12(worker2)
- **MacBook에서 접속**: NodePort 사용 시 `http://192.168.137.10:3xxxx` (또는 worker IP)
- **kubectl**: MacBook에서 `KUBECONFIG`로 master API(192.168.137.10:6443) 지정 후 실행

## 목표

- Pod, Deployment, Service 리소스 이해 및 생성
- ClusterIP / NodePort 동작 확인
- CoreDNS를 이용한 서비스 DNS 이름 해석
- `kubectl` 기본 사용법

## 실습 순서

### 1) Deployment / Pod 실행

```bash
kubectl apply -f deployment.yaml
kubectl get pods -o wide   # Pod IP 확인 (172.20.x.x)
kubectl get deploy
```

### 2) ClusterIP Service (클러스터 내부 통신)

```bash
kubectl apply -f service-clusterip.yaml
kubectl get svc
# 클러스터 안에서만 접근 가능. 디버그 Pod로 확인:
kubectl run debug --rm -it --image=busybox --restart=Never -- sh
# nslookup app-service
# wget -qO- http://app-service:8080/
```

### 3) NodePort Service (MacBook에서 접속)

```bash
kubectl apply -f service-nodeport.yaml
kubectl get svc app-nodeport
# NodePort 30080 이면 MacBook 브라우저에서:
# http://192.168.137.10:30080
# (또는 http://192.168.137.11:30080, http://192.168.137.12:30080)
```

### 4) 정리

```bash
kubectl delete -f service-nodeport.yaml -f service-clusterip.yaml -f deployment.yaml
```

## 매니페스트

- `deployment.yaml` — 테스트용 Deployment
- `service-clusterip.yaml` — ClusterIP Service
- `service-nodeport.yaml` — NodePort Service (MacBook에서 접근용)
