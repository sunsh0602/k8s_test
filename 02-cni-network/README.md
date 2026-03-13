# 2. CNI 네트워크

## 왜 중요한지

Pod networking 이해 — Pod 간 통신, Pod CIDR(172.20.0.0/16), 네트워크 정책의 기반. CNI 없이는 파드 네트워크가 동작하지 않음.

## 이 환경에서 (MacBook + VMware Fusion)

- **Pod CIDR**: 172.20.0.0/16  
- **노드**: 192.168.137.10, .11, .12  
- CNI는 `kubeadm init --pod-network-cidr=172.20.0.0/16` 후 Calico/Flannel 등 설치한 상태를 가정.

## 목표

- CNI(Calico, Flannel 등) 역할 이해
- Pod IP 할당 및 노드 간 파드 통신 확인
- 네트워크 플러그인 설정 및 동작 점검

## 실습 순서

### 1) CNI 설치 여부 확인

```bash
kubectl get pods -n kube-system | grep -E 'calico|flannel|weave|cilium'
# 노드가 Ready인지 확인 (CNI 없으면 NotReady)
kubectl get nodes -o wide
```

### 2) Pod IP 확인 (172.20.x.x)

```bash
kubectl apply -f 01-kubernetes-basics/deployment.yaml
kubectl get pods -o wide
# 각 Pod의 IP가 172.20.0.0/16 대역인지 확인
```

### 3) 노드 간 통신 테스트 (선택)

서로 다른 노드에 떠 있는 Pod끼리 통신. 디버그 Pod로 다른 Pod IP에 ping/curl:

```bash
# Pod IP 하나 확인 (예: 172.20.1.5)
kubectl get pods -o wide
kubectl run nettest --rm -it --image=nicolaka/netshoot --restart=Never -- ping -c 2 172.20.1.5
```

### 4) 정리

```bash
kubectl delete -f 01-kubernetes-basics/deployment.yaml
```

## 참고

- CNI 미설치 시: [Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart) 또는 [Flannel](https://github.com/flannel-io/flannel) 공식 문서대로 설치 (이 환경은 `--pod-network-cidr=172.20.0.0/16` 사용).
