# K8s-local 실습 환경

VMware Fusion 기반 로컬 Kubernetes 클러스터에서 단계별 실습을 위한 저장소입니다.

## 환경 구조

### 호스트 / VM

| 구분 | 설명 |
|------|------|
| **호스트** | MacBook |
| **가상화** | VMware Fusion |
| **노드 네트워크** | 192.168.137.0/24 |

| 노드 | IP | 역할 |
|------|-----|------|
| master | 192.168.137.10 | Control Plane |
| worker1 | 192.168.137.11 | Worker |
| worker2 | 192.168.137.12 | Worker |

### 클러스터 초기화 옵션

```bash
kubeadm init \
  --apiserver-advertise-address=192.168.137.10 \
  --pod-network-cidr=172.20.0.0/16 \
  --service-cidr=172.30.0.0/16
```

### 네트워크 구조

```
MacBook
  │
  │  (VMware Fusion network)
  ▼
Node IP (192.168.137.0/24)
  ├ master  192.168.137.10
  ├ worker1 192.168.137.11
  └ worker2 192.168.137.12

Kubernetes 내부:
  Pod network:     172.20.0.0/16
  Service network: 172.30.0.0/16
```

**트래픽 흐름:** MacBook → Node IP → Service IP (172.30.x.x) → Pod IP (172.20.x.x)

---

## 이 환경에서 실행하기 (MacBook + VMware Fusion)

실습은 아래를 전제로 작성되어 있습니다.

| 항목 | 설명 |
|------|------|
| **kubectl 실행 위치** | MacBook에서 실행 (master VM에 kubeconfig 복사 후 `export KUBECONFIG=...`) 또는 master(192.168.137.10) SSH 접속 후 실행 |
| **클러스터 접속** | `kubectl`이 master API(192.168.137.10:6443)로 연결되도록 설정 |
| **MacBook에서 서비스 접근** | NodePort: `http://192.168.137.10:3xxxx` (또는 worker IP). MetalLB 사용 시: `http://192.168.137.100` 등 할당된 External IP |
| **MetalLB 주소 풀** | Node 대역과 겹치지 않게 예: `192.168.137.100-192.168.137.120` 권장 |
| **VM 리소스** | Observability / Istio 실습 시 메모리 부족 시 Helm 값으로 replica·리소스 줄이기 |

각 실습 디렉토리에는 이 환경(노드 IP, Pod/Service CIDR)에 맞춘 매니페스트·명령·접속 방법이 포함되어 있습니다.

- **실습 시**: `kubectl apply -f ...` 등은 **저장소 루트(k8s-local)** 에서 실행하는 것을 권장합니다. 상대 경로가 루트 기준으로 작성되어 있습니다.

---

## 실습 목차

| 단계 | 주제 | 왜 중요한지 |
|------|------|-------------|
| 1 | [Kubernetes 기본](./01-kubernetes-basics/) | Pod / Service / Deployment / DNS |
| 2 | [CNI 네트워크](./02-cni-network/) | Pod networking 이해 |
| 3 | [MetalLB](./03-metallb/) | Baremetal LoadBalancer |
| 4 | [Ingress Controller](./04-ingress-controller/) | L7 routing |
| 5 | [Observability](./05-observability/) | metrics / logs / tracing |
| 6 | [Service Mesh](./06-service-mesh/) | sidecar / traffic control |
| 7 | [Gateway API](./07-gateway-api/) | Ingress 차세대 API |
| 8 | [Security](./08-security/) | RBAC / NetworkPolicy |
| 9 | [Storage](./09-storage/) | PV / PVC / CSI |
| 10 | [GitOps](./10-gitops/) | CI/CD 자동화 |
| 11 | [Runtime / Kernel](./11-runtime-kernel/) | container runtime / eBPF |
| 12 | [Operator / CRD](./12-operator-crd/) | Kubernetes 확장 |

각 디렉토리의 `README.md`에 실습 목표와 단계별 가이드가 있습니다.
