# 3. MetalLB

## 왜 중요한지

Baremetal LoadBalancer — 클라우드가 아닌 환경에서 `LoadBalancer` 타입 Service를 사용하려면 MetalLB(또는 유사 솔루션)가 필요함.

## 이 환경에서 (MacBook + VMware Fusion)

- **노드 네트워크**: 192.168.137.0/24  
- **MetalLB 주소 풀**: 노드와 겹치지 않게 `192.168.137.100-192.168.137.120` 사용 (아래 ConfigMap 참고)  
- **MacBook에서 접속**: Service에 할당된 External IP 예) `http://192.168.137.100`

## 목표

- MetalLB 설치 및 주소 풀 설정(Layer2 모드)
- LoadBalancer 타입 Service에 External IP 할당
- 호스트에서 External IP로 접근 테스트

## 실습 순서

### 1) MetalLB 설치

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml
# 또는 Helm:
# helm repo add metallb https://metallb.github.io/metallb
# helm install metallb metallb/metallb -n metallb-system --create-namespace
kubectl wait --for=condition=ready pod -l app=metallb -n metallb-system --timeout=120s
```

### 2) 주소 풀 설정 (이 환경용)

```bash
kubectl apply -f metallb-config.yaml
```

- `metallb-config.yaml`: Layer2 모드, 주소 풀 `192.168.137.100-192.168.137.120` (VM 네트워크와 동일 대역, MacBook에서 접근 가능)

### 3) LoadBalancer Service 테스트

```bash
kubectl apply -f 01-kubernetes-basics/deployment.yaml
kubectl apply -f service-loadbalancer.yaml
kubectl get svc app-lb
# EXTERNAL-IP에 192.168.137.100 등이 할당될 때까지 대기
# MacBook 브라우저: http://192.168.137.100:8080
```

### 4) 정리

```bash
kubectl delete -f service-loadbalancer.yaml -f 01-kubernetes-basics/deployment.yaml
```

## 매니페스트

- `metallb-config.yaml` — 이 환경(192.168.137.x)용 Layer2 주소 풀
- `service-loadbalancer.yaml` — 테스트용 LoadBalancer Service
