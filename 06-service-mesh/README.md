# 6. Service Mesh

## 왜 중요한지

sidecar / traffic control — 트래픽 제어, 재시도, mTLS, 관찰성을 애플리케이션 코드 변경 없이 메시에서 제공함.

## 이 환경에서 (MacBook + VMware Fusion)

- **리소스**: Istio는 상대적으로 무거움. VM 3대(마스터+워커2)에서 `minimal` 또는 `demo` 프로파일 권장. Bookinfo 전체보다 소규모 앱으로 먼저 테스트.
- **접속**: Ingress Gateway를 LoadBalancer(MetalLB)로 두면 MacBook에서 `http://192.168.137.1xx` 로 접속. Kiali/Jaeger도 동일하게 LB 또는 NodePort로 노출.
- **네트워크**: Pod CIDR 172.20.0.0/16, Service 172.30.0.0/16 그대로 사용 가능.

## 목표

- Istio(또는 다른 메시) 설치 및 sidecar 주입
- VirtualService / DestinationRule로 트래픽 라우팅·재시도
- (선택) mTLS, Kiali/Jaeger 연동

## 실습 순서 (예시)

1. `istioctl install --set profile=demo` (또는 minimal)로 설치.
2. 네임스페이스에 `istio-injection=enabled` 레이블로 sidecar 주입.
3. 샘플 앱 배포 후 VirtualService로 라우팅 규칙 적용.
4. Kiali/Jaeger는 별도 배포 후 MetalLB로 External IP 받아 MacBook에서 접속.
