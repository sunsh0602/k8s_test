# 7. Gateway API

## 왜 중요한지

Ingress 차세대 API — 역할 분리(Gateway vs Route), 다중 테넌시, 표준화된 L7 라우팅 정의. Ingress의 한계를 보완하는 공식 API.

## 이 환경에서 (MacBook + VMware Fusion)

- **사전 조건**: 6단계 Istio(또는 Gateway API를 지원하는 다른 컨트롤러) 설치 후 실습하는 것이 자연스러움. Istio가 Gateway API를 구현함.
- **접속**: Gateway 리소스의 주소는 Istio Ingress Gateway Service(LoadBalancer)에 의해 MetalLB IP로 노출 → MacBook에서 `http://192.168.137.1xx` 접속.
- **CRD**: Gateway API CRD는 Istio 설치 시 함께 올라오거나, 공식 manifest로 별도 설치.

## 목표

- Gateway API CRD(Gateway, HTTPRoute 등) 이해
- Gateway 리소스와 Controller(Istio/Envoy 등) 연동
- HTTPRoute로 호스트/경로 라우팅 정의 및 Ingress와 비교

## 실습 순서 (예시)

1. Gateway API CRD 설치(이미 Istio에 포함된 경우 생략).
2. Gateway 리소스 생성 후 Istio가 해당 Gateway를 수신하도록 설정.
3. HTTPRoute로 기존 서비스에 라우팅 규칙 연결.
4. MacBook에서 MetalLB IP로 접속해 라우팅 검증.
