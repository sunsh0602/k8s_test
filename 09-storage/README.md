# 9. Storage

## 왜 중요한지

PV / PVC / CSI — 스테이트풀 워크로드는 영구 볼륨이 필요함. PV/PVC 추상화와 CSI로 다양한 스토리지 백엔드를 통일된 방식으로 사용함.

## 이 환경에서 (MacBook + VMware Fusion)

- **Bare metal/VM**: 클라우드 스토리지 없음 → **hostPath**, **local** volume 또는 **local-path-provisioner** 등으로 실습.
- **hostPath**: 노드(192.168.137.10~12) 로컬 경로 사용. 테스트용으로만 권장(다중 노드에서 데이터 일관성 없음).
- **동적 프로비저닝**: [Rancher local-path-provisioner](https://github.com/rancher/local-path-provisioner) 설치 시 PVC만 만들어도 자동으로 PV 생성 가능.

## 목표

- PersistentVolume(PV), PersistentVolumeClaim(PVC) 개념 이해
- StorageClass와 동적 프로비저닝
- CSI 드라이버(로컬에서는 hostPath 등)로 볼륨 사용

## 실습 순서 (예시)

1. hostPath PV + PVC 수동 생성 후 Pod에서 mount해 파일 쓰기/읽기.
2. (선택) local-path-provisioner 설치 후 StorageClass로 PVC만 생성해 동적 프로비저닝 확인.
3. Pod 삭제 후 재생성해 같은 PVC로 데이터 유지되는지 확인.
