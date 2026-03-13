# 11. Runtime / Kernel

## 왜 중요한지

container runtime / eBPF — 컨테이너가 어떻게 실행되는지(containerd, CRI-O 등), 커널 수준 관찰/제어(eBPF)를 알면 트러블슈팅과 성능 이해에 도움이 됨.

## 이 환경에서 (MacBook + VMware Fusion)

- **실습 위치**: 런타임/커널 확인은 **VM 노드 안에서** 실행. MacBook에서 SSH로 master 또는 worker(192.168.137.10~12) 접속 후 `containerd`, `crictl`, `nsenter` 등 실행.
- **containerd**: kubeadm 클러스터는 기본적으로 containerd 사용. `ssh ubuntu@192.168.137.10` 후 `sudo crictl ps`, `sudo containerd config dump` 등으로 확인.
- **eBPF**: VM 커널 버전에 따라 eBPF 지원 여부 다름. Ubuntu 22.04 등에서는 bpftool, BCC 도구로 실습 가능. 리소스 부족 시 가벼운 도구만 사용.

## 목표

- CRI(Container Runtime Interface)와 containerd 등 런타임 이해
- (선택) eBPF 기반 도구로 네트워크/시스템 관찰
- 노드에서 런타임 설정 확인

## 실습 순서 (예시)

1. worker 노드 SSH 접속 후 `crictl ps`, `crictl pods`로 파드/컨테이너 목록 확인.
2. `containerd config default`로 기본 설정 확인. 필요 시 `/etc/containerd/config.toml` 경로 확인.
3. (선택) eBPF 가능한 커널이면 `bpftool prog list` 등으로 로드된 프로그램 확인.
