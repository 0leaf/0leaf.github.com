---
title: Kong Gateway 1. API Gateway, Reverse Proxy, Ingress
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Kong
tag:
  - Kong, API Gateway, Reverse Proxy, Ingress
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: API Gateway
article_tag2: Reverse Proxy
article_tag3: Ingress
article_section: section
meta_keywords: RAPI Gateway, Reverse Proxy
last_modified_at: "2021-07-10 17:00:00 +0800"
---

API Gateway, Reverse Proxy, Ingress 에 대해 설명합니다.

# 0. 들어가기 전에

Kuberentes 기반 MSA 서비스를 구성함에 있어 Gateway와 Ingress 부분을 어떻게 구성할지 고민이 필요했습니다. 그 과정에서 Kong Gateway가 대안으로 고려되었는데, 그 전에 API Gateway, Reverse Proxy, Ingress 등의 기본적인 개념을 정리하고 넘어가기 위해 글을 정리합니다.

# 1. API Gateway, Reverse Proxy, Ingress

헷갈리는 개념은 명확하게 짚고 넘어가야 나중에 문제가 발생하지 않으므로, 이미 알고있는 내용이라도 공신력(?) 있는 정보를 바탕으로 정확하게 짚어보도록 하겠습니다.

간단하게는 세 개념 모두 외부의 요청을 받아 내부의 서비스를 처리하는 기능을 합니다.

## 1. API Gateway

먼저 [wiki](https://en.wikipedia.org/wiki/API_management)에 관련된 내용을 참고해봅니다.

아래 내용을 보면 API Gateway의 기능 중 일부를 자세히 설명하고 있습니다.

> API frontend 역할을 하고, API 요청을 수신하고, 제한 및 보안 정책을 시행하고, 요청을 백엔드 서비스에 전달한 다음, 요청자에게 다시 응답을 전달하는 서버입니다.
> 게이트웨이에는 요청과 응답을 직접 조정 하고 수정 하는 변환 엔진이 포함되는 경우가 많습니다.
> 게이트웨이는 분석 데이터 수집 및 캐싱 제공과 같은 기능도 제공할 수 있습니다.
> 게이트웨이는 인증, 권한 부여, 보안, 감사 및 규정 준수를 지원하는 기능을 제공할 수 있습니다.
> 게이트웨이에는 요청과 응답을 직접 조정 하고 수정 하는 변환 엔진이 포함되는 경우가 많습니다.
> 리버스 프록시로 구현할 수 있습니다.

이런 기능을 하는 API Gateway는 [AWS](https://aws.amazon.com/ko/api-gateway/) 나 [GCP](https://cloud.google.com/api-gateway) 등의 public cloud에서 console로 쉽게 구성하도록 제공하기도 하며, 서두에 언급한 [Kong API Gateway](https://konghq.com/kong/) 와 같이 open source로 구성된 프로젝트도 있습니다.

![image](https://user-images.githubusercontent.com/79149004/125157471-22d2e780-e1a6-11eb-9888-cfe26fc89cff.png){: .align-center max-width="50%"}

## 2. Reverse Proxy

마찬가지로 [wiki](https://en.wikipedia.org/wiki/Reverse_proxy)에 관련된 내용을 참고해봅니다.

아래 내용은 Reverse Proxy의 기능 중 일부를 설명하고 있는데 표현이 다르지만 사실 API Gateway에서 표현된 내용과 일치하는 부분들이 있습니다.

> 역방향 프록시를 다른 기술과 함께 사용하여 내부 서버 간의 로드 균형 을 조정 합니다.
> 역방향 프록시는 정적 콘텐츠 캐시를 유지할 수 있으므로 이러한 내부 서버와 내부 네트워크의 부하를 더욱 줄일 수 있습니다.
> 역방향 프록시가 클라이언트와 역방향 프록시 간의 통신 채널에 압축 또는 TLS 암호화 와 같은 기능을 추가하는 것도 일반적입니다.

리버스 프록시 서버는 [Apache](https://en.wikipedia.org/wiki/Apache_HTTP_Server) , [Nginx](https://en.wikipedia.org/wiki/Nginx) 및 Caddy 와 같은 널리 사용되는 오픈 소스 웹 서버 에서 구현됩니다.

![image](https://user-images.githubusercontent.com/79149004/125157477-28c8c880-e1a6-11eb-97b2-0e2f5046e17e.png){: .align-center max-width="50%"}

## 3. Ingress

이번엔 kubernetes에서 자주 언급되는 용어인 [Ingress](https://kubernetes.io/ko/docs/concepts/services-networking/ingress/)에 대한 내용을 살펴봅니다.

> 클러스터 내의 서비스에 대한 외부 접근을 관리하는 API 오브젝트이며, 일반적으로 HTTP를 관리함.
> 인그레스는 부하 분산, SSL 종료, 명칭 기반의 가상 호스팅을 제공할 수 있다.

Ingress 역할을 하기 위해 nginx ingress, istio ingress 등의 구성으로 외부 요청을 내부로 전달하는 목적의 기능을 수행합니다.

![image](https://user-images.githubusercontent.com/79149004/125157482-2fefd680-e1a6-11eb-8c6a-7d3950ca7b46.png){: .align-center max-width="50%"}

kubernetes의 Ingress의 개념은 결국 API Gateway와 Reverse Proxy의 개념과 맞닿아 있습니다. 외부 요청을 받아 내부의 서비스로 전달하는 과정을 어떻게 구성할지 고민이 필요합니다.

# 2. 정리

위 내용들을 살펴보면 외부 요청을 받아 내부의 서비스로 전달하는 목적에 대해 유사한 기능들을 설명하고 있습니다. 실제로 API Gateway가 Proxy보다 더 상위 개념이라고 볼 수 있습니다.

간단한 서버 구성의 경우 외부의 호출을 처리하기 위해 nginx proxy 서버로 처리 가능합니다.

다만, 서비스 영역이 커지면서 외부의 요청을 제한하거나 처리하기 위한 인증 등의 처리가 필요할 경우 앞단에 API Gateway로 통합된 기능을 처리하게 됩니다.

실제로 앞서 언급된 Kong API Gateway는 개발 기반 자체가 nginx 위에서 lua로 개발된 plugin들의 구성으로 되어있다고 합니다.

[akana 에서 작성한 글](https://www.akana.com/blog/api-proxy-vs-api-gateway)에 적당한 그림이 있어 첨부하여 이 글을 마무리하고자 합니다.

![image](https://user-images.githubusercontent.com/79149004/125157488-37af7b00-e1a6-11eb-8ecc-10c65ef3a042.png){: .align-center max-width="50%"}

# 3. 참고자료

[https://en.wikipedia.org/wiki/API_management](https://en.wikipedia.org/wiki/API_management)

[https://en.wikipedia.org/wiki/Reverse_proxy](https://en.wikipedia.org/wiki/Reverse_proxy)

[https://kubernetes.io/ko/docs/concepts/services-networking/ingress/](https://kubernetes.io/ko/docs/concepts/services-networking/ingress/)

[https://www.akana.com/blog/api-proxy-vs-api-gateway](https://www.akana.com/blog/api-proxy-vs-api-gateway)

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2F0leaf.github.io%2Fkong%2FKong-Gateway-1-API-Gateway-Reverse-Proxy-Ingress%2F&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=count&edge_flat=false)](https://hits.seeyoufarm.com)
