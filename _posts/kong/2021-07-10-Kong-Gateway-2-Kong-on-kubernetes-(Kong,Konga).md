---
title: Kong Gateway 2. Kong on kubernetes  (Kong, Konga)
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Kong
tag:
  - Kong, Konga
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: Kong
article_tag2: Konga
article_tag3: API Gateway
article_section: section
meta_keywords: Kong, Konga
last_modified_at: "2021-07-11 15:53:00 +0800"
---

Kong, Konga에 대한 설명 및 구성 과정을 설명합니다.

# 0. 들어가기 전에

먼저 Kong API Gateway를 도입하기 전에 istio ingress 구성이나, nginx ingress 구성이 k8s 내에 완료되어 외부 요청에 대한 처리를 할 수 있음을 가정합니다. 특히 istio ingress로 구성되어 있는 상태를 기본으로 가정합니다.

![Untitled](https://user-images.githubusercontent.com/79149004/125184646-828aca80-e25a-11eb-9553-931cc05365c1.png)

[https://kubernetes.io/ko/docs/concepts/services-networking/ingress/](https://kubernetes.io/ko/docs/concepts/services-networking/ingress/)

![Untitled 1](https://user-images.githubusercontent.com/79149004/125184648-86b6e800-e25a-11eb-8ee8-2590bcdb749e.png)

위 그림은 각각 ngnix igress와 istio ingress 구성을 통해 외부 요청을 처리해주는 것을 표현합니다. 이러한 ingress들은 주로 resverse proxy의 기능을 하며 인증 등의 추가적인 기능을 위해 API Gateway가 필요할 경우 ingress 단 혹은 더 앞단에 이를 대체하는 API Gateway를 두고자 하며, 이를 Kong 으로 구성하고자 합니다.

[https://istio.io/v1.9/docs/examples/virtual-machines/](https://istio.io/v1.9/docs/examples/virtual-machines/)

[https://www.nginx.com/blog/wait-which-nginx-ingress-controller-kubernetes-am-i-using/](https://www.nginx.com/blog/wait-which-nginx-ingress-controller-kubernetes-am-i-using/)

# 1. Kong on Kubernetes

[Istio 구성](https://istio.io/v1.9/docs/setup/getting-started/)을 마친 kubernetes 환경에서 kong gateway로 ingress 기능을 처리하는 구조 및 설명이 [다음 글](https://konghq.com/blog/kong-istio-setting-service-mesh-kubernetes-kiali-observability/)에 잘 설명되어 있습니다.

본 글에 내용중 아래 그림이 있는데 ingress의 역할을 하게 될 Kong API Gateway가 앞에서 요청을 받아주고, K8S 내의 서비스들로 Upstream 요청을 전달하게 될 것입니다.

![Untitled 2](https://user-images.githubusercontent.com/79149004/125184650-87e81500-e25a-11eb-8d61-11f03b66631f.png)

Isito 구성 과정에서 virtual service manifest 변경을 통해 routing을 설정하고 각 서비스로 요청을 전달했는데, Kong API Gateway로 구성하게 되면 직접 route 주소에 대해 service를 연결시킬 수 있습니다.

또한 Konga라는 front web page를 통해 Kong Admin의 설정을 쉽게 변경할 수 있는데, 그 과정도 다루어 보도록 하겠습니다.

아래 설치 환경은 \*\*\*\*Kubernetes 내 에서 진행됨을 말씀드립니다.

# 2. Kong

## 2.1 Kong

[링크](https://github.com/Kong/kong) 에서 kong에 대해 자세히 설명하고 있으며 API Gateway의 구현체입니다. 설명에 따르면 nginx 기반 lua plugin들로 그 기능들을 수행한다고 합니다. Kong API Gateway는 Enterprise 버전과, OSS(Open Source) 버전을 모두 제공하고 있습니다.

> Kong can help by acting as a gateway (or a sidecar) for microservices requests while providing load balancing, logging, authentication, rate-limiting, transformations, and more through plugins.

![Untitled 3](https://user-images.githubusercontent.com/79149004/125184651-8880ab80-e25a-11eb-8214-547e72300772.png)

설명에 따르면, load balancing, 로깅, 인증 등 API Gateway가 가져야할 기능들을 다양한 플러그인을 통해 제공할 수 있다고 합니다.

## 2.2 Kong 설치

기본적으로 공식 helm chart로 kong을 설치하게 되면 아래와 같은 방식으로 설치하도록 가이드하고 있습니다.

```bash
$ helm repo add kong https://charts.konghq.com
$ helm repo update

# Helm 2
$ helm install kong/kong

# Helm 3
$ helm install kong/kong --generate-name --set ingressController.installCRDs=false
```

[https://github.com/Kong/charts](https://github.com/Kong/charts)

하지만 위 설정대로 진행하면 kong은 dbless 방식으로 뜨게 되고, 나중에 konga 툴로 service 나 route 등을 등록할 수 없게 됩니다. 따라서 [링크](https://charts.bitnami.com/bitnami)에서 구성된 kong chart는 default로 postgres db가 K8S 내에서 kong과 같이 뜨도록 구성되어 있습니다.

물론 kong 공식 charts에서 yaml manifest를 변경함으로 db 구성을 지정할 수 있지만, 효율적인 과정을 위해 아래 내용으로 진행하도록 합니다.

**kong 설치 진행 (with posgres)**

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install kong \
--set service.exposeAdmin=true \
--set ingressController.installCRDs=false \
--set namespace=kong \
bitnami/kong
```

[링크](https://artifacthub.io/packages/helm/bitnami/kong)에서 살펴보면, 여러가지 옵션을 변경할 수 있도록 문서화가 잘 되어있습니다.

기본적으로 bitnami의 helm chart는 postrgres가 default로 설정되어 있기 때문에 위 구성대로 kong을 설치하게 되면 postgres db가 함께 뜨고, kong admin의 port는 expose 됩니다.

# 3. Konga

## 3.1 Konga

[링크](https://github.com/pantsel/konga)에서 konga에 대한 설명을 확인하실 수 있습니다. 기본적으로 kong은 API들을 구성할때 kong admin 주소로 rest 요청을 통해 설정합니다. 번거로운 작업이 될 수 있고 익숙하지 않은 사람에겐 불편한 작업이 됩니다.

kong enterprise 버전에서는 admin page를 제공하는 것 같은데, open source 버전도 konga를 이용해 admin 페이지를 구성할 수 있습니다.

![Untitled 4](https://user-images.githubusercontent.com/79149004/125184652-89194200-e25a-11eb-9035-96b00fbbf98f.png)

> Manage all Kong Admin API Objects.

> Import Consumers from remote sources (Databases, files, APIs etc.).

> Manage multiple Kong Nodes.

> Backup, restore and migrate Kong Nodes using Snapshots.

> Monitor Node and API states using health checks.

> Email & Slack notifications.

> Multiple users.

> Easy database integration (MySQL, postgresSQL, MongoDB).

## 3.2 konga 설치

konga를 활용해서 다양한 설정을 적용하려면, **Kong이 db와 함께 구성**되어 있어야 합니다. dbless로 구성될 경우 API 설정들의 조회는 가능하나, 추가/수정은 불가능합니다. 앞서 소개해드린 [bitnami helm chart](https://artifacthub.io/packages/helm/bitnami/kong)로 구성하면 자동으로 postgres db가 함께 구성되는데, 실제 서비스에 적용할 때는 안정적으로 구성된 db를 연동하는 것이 필요해 보입니다.

**konga 설치 진행**

konga helm chart 주소에 있는 내용을 바탕으로 설치하고 repository에 있는 helm chart를 직접 설치합니다.

[https://github.com/pantsel/konga](https://github.com/pantsel/konga)

```bash
git clone https://github.com/pantsel/konga.git
cd konga/charts
helm install konga konga/
```

# 4. Kong, Konaga 연동

kubectl get service 명령으로 아래와 같이 설치된 것을 확인하실 수 있습니다.

여기서 저는 외부 접속을 허용하기 위해 kong, konga를 LoadBalancer Type 으로 변경했습니다.

본 글에서 nlb 주소를 변경하였지만, 표시된 [xxx.ap-northeast-2.elb.amazonaws.com](http://xxx.ap-northeast-2.elb.amazonaws.com) 주소로 접속하시면 계정 생성 후 아래 화면을 보실 수 있습니다.

```bash
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP                                                                    PORT(S)                                                    AGE
kong                       LoadBalancer   172.20.249.30    xxx.ap-northeast-2.elb.amazonaws.com    80:32388/TCP,443:31964/TCP,8001:31018/TCP,8444:31915/TCP   17d
kong-metrics               ClusterIP      172.20.80.144    <none>                                                                         9119/TCP                                                   17d
kong-postgresql            ClusterIP      172.20.252.142   <none>                                                                         5432/TCP                                                   17d
kong-postgresql-headless   ClusterIP      None             <none>                                                                         5432/TCP                                                   17d
konga                      LoadBalancer   172.20.126.171   xxx.ap-northeast-2.elb.amazonaws.com   80:31741/TCP                                               17d
```

![Untitled 5](https://user-images.githubusercontent.com/79149004/125184653-89b1d880-e25a-11eb-8311-70d86f339947.png)

APPLICATION-CONNECTIONS 페이지에서 위와 같이 kong admin 주소를 연결해주면 Kong API Gateway의 설정된 정보들을 읽을 수 있습니다.

NLB로 public url 주소가 있는 경우 그 주소를 입력해도 되고, 같은 네트웍 상에서 구성되었다면 위와 같이 service 명으로도 연동 가능합니다.

# 6. API 설정 테스트

![Untitled 6](https://user-images.githubusercontent.com/79149004/125184655-89b1d880-e25a-11eb-96bb-71c8255beb5a.png)

먼저 Kong API Gateway의 구성은 위 그림을 통해 보면 자세히 알 수 있습니다.

간단한 API 들의 연동을 테스트 해보려고 하는데, 최소한으로 Service → Route 를 설정해야 합니다.

뒤 내용에서 살펴보겠지만 Route는 Service에 종속되고, Consumer는 Route에 종속되는 형태로 구성됩니다.

Konga를 설치하지 않았다면 REST 기반의 [Admin API](https://docs.konghq.com/gateway-oss/2.4.x/admin-api/) 로 구성하는 방법이 있습니다.

![Untitled 7](https://user-images.githubusercontent.com/79149004/125184656-8a4a6f00-e25a-11eb-8587-02433683ce03.png)

Konga를 통해 위와 같은 구성의 포털로 호출하는 API를 설정하는 것을 살펴보도록 하겠습니다.

## 6.1 Service 구성

![Untitled 8](https://user-images.githubusercontent.com/79149004/125184658-8a4a6f00-e25a-11eb-9d90-81cdcdf1ce60.png)

왼쪽 탭의 Services에서 ADD NEW SERVICE를 누르면 위 화면을 볼 수 있습니다.

Url을 위와 같이 구성해주면, Host, Port, Path 등이 자동으로 들어가게 됩니다.

![Untitled 9](https://user-images.githubusercontent.com/79149004/125184659-8ae30580-e25a-11eb-99d0-96cb39c06ecc.png)

생성된 google service를 선택하면 필요한 내용들이 자동으로 들어가있는 것을 볼 수 있고, 왼쪽 탭에 Routes와Plugins을 통해 Service에 Routes와 Plugins이 종속되어 있음을 확인할 수 있습니다.

## 6.2 Route 구성

![Untitled 10](https://user-images.githubusercontent.com/79149004/125184660-8ae30580-e25a-11eb-9077-4c3599bf4297.png)

이제 사용자가 호출할 때 http:[/](http://kong)/{kong address}/{route} 로 요청할 수 있도록 Routes를 구성해야 하는데, 왼쪽 탭의 Routes를 누르면 사진처럼 **YOU CAN ONLY CREATE ROUTES FROM A SERVICE PAGE**라는 링크를 볼 수 있습니다.

누르면 결국 6.1에서 봤던 서비스 화면으로 이동하게 됩니다.

![Untitled 11](https://user-images.githubusercontent.com/79149004/125184662-8b7b9c00-e25a-11eb-9dfc-f7037b9bb873.png)

![Untitled 12](https://user-images.githubusercontent.com/79149004/125184663-8b7b9c00-e25a-11eb-92f3-c8cead540820.png)

여러 설정을 구성할 수 있지만 테스트를 위해 붉게 표시된 부분들만 구성해주도록 합니다.

Paths와 Meethods는 반드시 **엔터 를 눌러서 회색 모양**으로 만들어주셔야 합니다.

그렇지 않으면 설정이 저장되지 않습니다.

## 6.3 Consumer 구성

6장 도입부 그림을 보면 consumer 구성을 볼 수 있는데, 인증 등의 처리를 위해 consumer를 구성할 수 있습니다. (특정 사람만 google로 요청할 수 있도록 인증/인가)

하지만 이 글에선 기본적인 API 설정에 대해서만 다루는 것이 목표이기 때문에 본 글에서 consumer는 다루지 않도록 하며 기회가 되면 다른 chapter에서 다루어 보도록 하겠습니다.

## 6.4 테스트

```bash
curl -X GET {kong nlb address}/google
curl -X GET {kong nlb address}/naver
curl -X GET {kong nlb address}/kakao
```

# 7. 정리

위 과정은 kong, konga 모두를 연동하고 다양한 실험을 진행한 후에 정리한 글입니다.

여러 글을 참고하여 구성했으나, db없이 구성했다가 다시 삭제하고 등의 시행착오를 겪었습니다. 별 내용은 없고 helm chart에 대한 자세한 설명을 섞진 않았으나 실험을 진행하기에 알맞게 잘 구성된 helm chart와 과정을 소개하는 것과 직접 시도해보지 않고 해당 과정으로 어떤 식으로 진행되는 지를 공유드리는 것이 목적임을 밝힙니다.

# 6. 참고자료

[https://kubernetes.io/ko/docs/concepts/services-networking/ingress/](https://kubernetes.io/ko/docs/concepts/services-networking/ingress/)

[https://istio.io/v1.9/docs/examples/virtual-machines/](https://istio.io/v1.9/docs/examples/virtual-machines/)

[https://www.nginx.com/blog/wait-which-nginx-ingress-controller-kubernetes-am-i-using/](https://www.nginx.com/blog/wait-which-nginx-ingress-controller-kubernetes-am-i-using/)

[https://github.com/Kong/charts](https://github.com/Kong/charts)

[https://github.com/pantsel/konga](https://github.com/pantsel/konga)
