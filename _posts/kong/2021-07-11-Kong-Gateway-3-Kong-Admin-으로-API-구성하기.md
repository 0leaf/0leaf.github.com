---
title: Kong Gateway 3. Kong Admin 으로 API 구성하기
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Kong
tag:
  - Kong
  - Kong Admin
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: Kong
article_tag2: Kong Admin
article_tag3: API Gateway
article_section: section
meta_keywords: Kong, Kong Admin
last_modified_at: "2021-07-10 15:50:00 +0800"
---

Kong, Kong Admin에 대한 설명 및 구성 과정을 설명합니다.

# 0. 들어가기 전에

이전 장에서 Kong API Gateway와 Konga를 K8S에서 구성하여 API 간단히 테스트 해봤습니다. 하지만 Kong의 많은 기능들을 제대로 이해하기 위해 공식 문서를 통해 하나씩 살펴보는 것이 필요하겠다라는 생각이 들었습니다.

아래 과정들은 konga를 설치하면 UI로 쉽게 구성할 수 있지만, konga를 사용하지 않는 경우도 있고, infra code로 관리하게 될 경우 기본이되는 REST 구성을 살펴보기 위해 Kong Admin API 를 통해 API 구성을 해본 과정을 기술합니다.

혹시 Kong 환경이 구성되지 않으셨다면 [이 글](<https://0leaf.github.io/kong/Kong-Gateway-2-Kong-on-kubernetes-(Kong,Konga)/>)을 참고하시기 바랍니다.

# 1. Kong Gateway

앞서 이야기한 내용처럼 Kong Gateway는 Nginx 기반으로 Gateway 기능을 수행하기 위한 목적으로 만들어 졌습니다. Kong은 Reverse Proxy로 많이 쓰이는 Nginx 위에 Lua 언어로 플러그인들이 구성되어 Reverse Proxy의 기능 외에도 API Gateway가 갖춰야 할 다양한 기능들을 제공합니다.

Micro Service Architecture 로 시스템을 설계함에 있어 Kong은 다양한 plugin 구성으로 큰 장점을 가져올 수 있다고 말하고 있으며 Kong Gateway as a paragon of microservice architecture 라고 [kong 문서](https://docs.konghq.com/gateway-oss/)에서 이야기하고 있습니다.

# 2. Getting Started Guide

## 2.1 Overview

kong gateway 서비스는 Enterprise와 OSS(OpenSource) 구성으로 나누어져 있습니다. 이 글에서 살펴볼 내용은 OSS 에 해당하는 부분입니다. 청록색 부분이 Enterprise Version의 기능을 의미하는데, Kong Manager같은 경우 [Konga](https://github.com/pantsel/konga) 라는 kong admin을 UI로 관리할 수 있는 open source 대체 툴이 존재합니다.

![Untitled](https://user-images.githubusercontent.com/79149004/125185346-60477b80-e25f-11eb-9314-7328c8ca5e6a.png)

[https://docs.konghq.com/getting-started-guide/2.4.x/overview/](https://docs.konghq.com/getting-started-guide/2.4.x/overview/)

위 그림은 단순히 Kong에 대한 그림 뿐만 아니라 일반적인 API Gateway들의 특징들을 의미하기도 합니다.

![Untitled 1](https://user-images.githubusercontent.com/79149004/125185350-64739900-e25f-11eb-8034-282a4417659b.png)

API Client로부터 8000/8443 로 프록시된 포트로부터 요청을 받고 Backend API로 요청을 전달합니다. Admin의 경우 Restful 방식으로 여러 설정들을 구성할 수 있는데 helm으로 구성할 경우 기본적으로 8001로 expose 되어있습니다.

따라서 **kubectl get service 명령을 통해 port가 어떻게 포워딩 되어있는지 확인**하시길 바랍니다.

## 2.2 Prepare to Administer

[링크](https://docs.konghq.com/getting-started-guide/2.4.x/prepare/#verify-the-kong-gateway-configuration) 의 원글을 실험해보면서 해당 과정을 조금 더 자세히 이해해보도록 하겠습니다.

```c
NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP                                                                    PORT(S)                                                    AGE
konga                            LoadBalancer   172.20.163.27    xxx1.ap-northeast-2.elb.amazonaws.com   80:31458/TCP                                               19h
my-release-kong                  LoadBalancer   172.20.244.82    xxx2.ap-northeast-2.elb.amazonaws.com   80:31067/TCP,443:32020/TCP,8001:31014/TCP,8444:31241/TCP   19h
my-release-kong-metrics          ClusterIP      172.20.109.139   <none>                                                                         9119/TCP                                                   19h
my-release-postgresql            ClusterIP      172.20.17.148    <none>                                                                         5432/TCP                                                   19h
my-release-postgresql-headless   ClusterIP      None             <none>                                                                         5432/TCP                                                   19h
```

kubectl get svc -n default 명령을 통해 초기 kong, konga가 구성된 서비스들을 확인해볼 수 있습니다.

편의를 위해 konga, my-release-kong 두개를 LoadBalancer type으로 변경해 외부에서 요청할 수 있도록 LoadBalancer로 타입을 변경하여 elb를 붙였습니다.

지금은 my-release-kong 만 살펴볼 예정인데, 포트를 보면 80:31067/TCP, 443:32020/TCP, 8001:31014/TCP, 8444:31241/TCP 가 포워딩 된 것을 볼 수 있습니다.

이전 단계에서 언급했던 것 처럼 Admin은 8001, API 요청은 80(8000), 443(8443), 으로 요청을 받아주도록 구성되었습니다.

### 2.2.1 Admin API 테스트

![Untitled 2](https://user-images.githubusercontent.com/79149004/125185351-64739900-e25f-11eb-8eb9-d317ca3b03f5.png)

공식 문서의 위 항목 중 여기서는 OSS의 Spec을 살펴 볼 것이므로 Using the Admin API를 선택합니다.

**요청**

```bash
curl -i -X GET xxx2.ap-northeast-2.elb.amazonaws.com:8001
```

**응답**

![Untitled 3](https://user-images.githubusercontent.com/79149004/125185352-650c2f80-e25f-11eb-9604-9c600cdbec2c.png)

위 결과처럼 응답이 내려오는데 API Gateway 설정과 관련된 굉장히 많은 정보를 포함하고 있으므로 응답 전문은 생략합니다.

## 2.3 Expose your Services

여기서 Service 와 Route라는 개념을 다룹니다.

> Service is an entity representing an external upstream API or microservice.

> Routes determine how (and if) requests are sent to their Services after they reach Kong Gateway.

각각 정리된 내용을 살펴보면 Service는 upstream API 나 microservice 에 대한 정보를 포함하여 정의되고, Route는 그렇게 정의된 Service를 외부 요청으로부터 연결해준다고 불 수 있습니다.

그런 이유로 구성 순서는 Service 정의 → Route 연결 이 됩니다.

![Untitled 4](https://user-images.githubusercontent.com/79149004/125185353-65a4c600-e25f-11eb-8925-c84e14652399.png)

### 2.3.1 Add a Service

![Untitled 5](https://user-images.githubusercontent.com/79149004/125185354-65a4c600-e25f-11eb-8e5a-e2df47802d36.png)

Using the Admin API를 선택해서 Service 등록 과정을 살펴봅니다.

조금 구성을 변경해서 google.com을 example_service의 이름을 갖는 서비스로 등록 해보도록 하겠습니다.

**요청**

```bash
curl -i -X POST http://xxx2.ap-northeast-2.elb.amazonaws.com:8001/services \
  --data name=example_service \
  --data url='https://google.com'
```

**응답**

```json
{
  "port": 443,
  "name": "example_service",
  "client_certificate": null,
  "path": null,
  "ca_certificates": null,
  "write_timeout": 60000,
  "connect_timeout": 60000,
  "tls_verify": null,
  "protocol": "https",
  "tls_verify_depth": null,
  "host": "google.com",
  "created_at": 1623725919,
  "retries": 5,
  "id": "174a56d3-69b3-4211-afe2-e0405dc61ce4",
  "tags": null,
  "read_timeout": 60000,
  "updated_at": 1623725919
}
```

### 2.3.2 Add a Route

![Untitled 6](https://user-images.githubusercontent.com/79149004/125185355-663d5c80-e25f-11eb-85aa-b3dc2f52b09d.png)

Using the Admin API를 선택해서 Route 등록 과정을 살펴봅니다.

여기서 살펴볼만한 점은 POST 주소를 보면 services/example_services/rotues
의 restful한 리소스 구조로 요청을 보내고 있는데, routes가 services 리소스에 종속되어 있음을 알 수 있습니다.

또한 —data 옵션으로 'paths[]=/mock' 를 주고 있는데 사용자가 Kong API Gateway를 통해 요청할 때 /mock 로 보내면 example_service로 연결함을 의미합니다.

**Route 등록**

**요청**

```bash
curl -i -X POST http://xxx2.ap-northeast-2.elb.amazonaws.com:8001/services/example_service/routes \
  --data 'paths[]=/mock' \
  --data name=mocking
```

**응답**

```json
{
  "name": "mocking",
  "paths": ["/mock"],
  "methods": null,
  "tags": null,
  "destinations": null,
  "request_buffering": true,
  "response_buffering": true,
  "strip_path": true,
  "service": { "id": "174a56d3-69b3-4211-afe2-e0405dc61ce4" },
  "https_redirect_status_code": 426,
  "preserve_host": false,
  "protocols": ["http", "https"],
  "regex_priority": 0,
  "path_handling": "v0",
  "created_at": 1623726177,
  "updated_at": 1623726177,
  "headers": null,
  "hosts": null,
  "id": "81580cf8-3a6c-4b37-95df-5e810f41b07e",
  "snis": null,
  "sources": null
}
```

### 2.3.3 연결 확인

아래 요청과 같이 보냅니다. 주의할 점은 저 처럼 helm으로 K8S 내 kong을 구성하면 기본으로 8000이 아니라 80으로 port forwarding 되어있습니다.

또 이전 API 등록 예제는 Admin(8001)로 보냈는데, 등록이 완료된 이후로는 Kong API Gateway(80/8000)으로 보내고 있음을 알 수 있습니다.

**요청**

```bash
curl -i -X GET http://xxx2.ap-northeast-2.elb.amazonaws.com:80/mock/request
```

**응답**

```json
HTTP/1.1 404 Not Found
Content-Type: text/html; charset=UTF-8
Content-Length: 1568
Connection: keep-alive
Referrer-Policy: no-referrer
Date: Tue, 15 Jun 2021 03:08:24 GMT
Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000,h3-T051=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"
X-Kong-Upstream-Latency: 171
X-Kong-Proxy-Latency: 109
Via: kong/2.4.1

<!DOCTYPE html>
<html lang=en>
  <meta charset=utf-8>
  <meta name=viewport content="initial-scale=1, minimum-scale=1, width=device-width">
  <title>Error 404 (Not Found)!!1</title>
  <style>
    *{margin:0;padding:0}html,code{font:15px/22px arial,sans-serif}html{background:#fff;color:#222;padding:15px}body{margin:7% auto 0;max-width:390px;min-height:180px;padding:30px 0 15px}* > body{background:url(//www.google.com/images/errors/robot.png) 100% 5px no-repeat;padding-right:205px}p{margin:11px 0 22px;overflow:hidden}ins{color:#777;text-decoration:none}a img{border:0}@media screen and (max-width:772px){body{background:none;margin-top:0;max-width:none;padding-right:0}}#logo{background:url(//www.google.com/images/branding/googlelogo/1x/googlelogo_color_150x54dp.png) no-repeat;margin-left:-5px}@media only screen and (min-resolution:192dpi){#logo{background:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) no-repeat 0% 0%/100% 100%;-moz-border-image:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) 0}}@media only screen and (-webkit-min-device-pixel-ratio:2){#logo{background:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) no-repeat;-webkit-background-size:100% 100%}}#logo{display:inline-block;height:54px;width:150px}
  </style>
  <a href=//www.google.com/><span id=logo aria-label=Google></span></a>
  <p><b>404.</b> <ins>That’s an error.</ins>
  <p>The requested URL <code>/request</code> was not found on this server.  <ins>That’s all we know.</ins>
```

구글로 부터 404 응답이 내려온 것을 확인할 수 있습니다.

## 2.4 Protect your Services

이 장에서는 API Gateway의 기능 중 Rate limit 을 살펴보도록 합니다. 조금 당연한 이유일 수 있지만 원 글에서는 아래와 같이 Rate limit의 필요성을 설명하고 있습니다.

> Rate limiting protects the APIs from accidental or malicious overuse. Without rate limiting, each user may request as often as they like, which can lead to spikes of requests that starve other consumers. After rate limiting is enabled, API calls are limited to a fixed number of requests per second.

쉽게 이아기해서 초당 요청 횟수를 제한하여 service가 예상된 요청에 대한 응답을 내려줄 수 있도록 제한하는 기능을 의미합니다.

### 2.4.1 Set up Rate Limiting

![Untitled 7](https://user-images.githubusercontent.com/79149004/125185356-66d5f300-e25f-11eb-8293-8978535d2378.png)

위 데이터 구성을 살펴보면, 분당 5회의 요청으로 제한하는 설정을 data로 주고 있습니다.

**요청**

```bash
curl -i -X POST http://xxx2.ap-northeast-2.elb.amazonaws.com:8001/plugins \
  --data name=rate-limiting \
  --data config.minute=5 \
  --data config.policy=local
```

**응답**

```json
{
  "name": "rate-limiting",
  "enabled": true,
  "tags": null,
  "config": {
    "redis_database": 0,
    "redis_host": null,
    "redis_port": 6379,
    "path": null,
    "redis_password": null,
    "limit_by": "consumer",
    "second": null,
    "minute": 5,
    "hour": null,
    "day": null,
    "month": null,
    "month": null,
    "policy": "local",
    "fault_tolerant": true,
    "hide_client_headers": false,
    "header_name": null,
    "redis_timeout": 2000
  },
  "consumer": null,
  "created_at": 1623727072,
  "service": null,
  "id": "a01a7967-c6aa-4168-83be-15654c333413",
  "route": null,
  "protocols": ["grpc", "grpcs", "http", "https"]
}
```

### 2.4.2 Validate Rate Limiting

분당 5회로 요청 제한이 설정되었으므로 간단하게 curl로 1분 내 5회 이상 요청을 해보도록 하겠습니다.

여기서도 등록 이후에는 Admin(8001)이 아닌 API Gateway(80/8000)로 요청을 보내야 합니다.

**요청**

```json
curl -i -X GET http://xxx2.ap-northeast-2.elb.amazonaws.com:80/mock/request

```

**응답**

```json
{
  "message": "API rate limit exceeded"
}
```

## 2.5 Improve Performance

이 장에서는 proxy caching 기능을 살펴봅니다. plugin 구성을 통해 쉽게 기능을 반영할 수 있습니다. proxy cache 기능이 무엇인지에 대해 아래와 같이 설명하고 있습니다

> Kong Gateway delivers fast performance through caching. The Proxy Caching plugin provides this fast performance using a reverse proxy cache implementation. It caches response entities based on the request method, configurable response code, content type, and can cache per Consumer or per API.

쉽게 이야기하면 이전에 요청왔던 정보들을 기억하고 있다가 동일한 요청에 대해 Servce로 전달해 응답받을 필요가 없으므로 바로 사용자에게 내려주는 기능을 의미합니다.

### 2.5.1 Set up the Proxy Caching plugin

![Untitled 8](https://user-images.githubusercontent.com/79149004/125185357-66d5f300-e25f-11eb-94f6-c2619c4ba0d7.png)

내용을 살펴보면 30초간 TTL 구성동안 memory에 같은 요청이라면 저장 해두고 바로 응답으로 내려주도록 설정함을 알 수 있습니다.

**요청**

```json
curl -i -X POST http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:8001/plugins \
  --data name=proxy-cache \
  --data config.content_type="application/json; charset=utf-8" \
  --data config.cache_ttl=30 \
  --data config.strategy=memory
```

**응답**

```json
{
  "name": "proxy-cache",
  "enabled": true,
  "tags": null,
  "config": {
    "content_type": ["application/json; charset=utf-8"],
    "vary_query_params": null,
    "cache_control": false,
    "request_method": ["GET", "HEAD"],
    "vary_headers": null,
    "response_code": [200, 301, 404],
    "cache_ttl": 30,
    "storage_ttl": null,
    "strategy": "memory",
    "memory": { "dictionary_name": "kong_db_cache" }
  },
  "consumer": null,
  "created_at": 1623727908,
  "service": null,
  "id": "f5e6f07b-c6ca-45e2-9f3b-02af465b7130",
  "route": null,
  "protocols": ["grpc", "grpcs", "http", "https"]
}
```

## 2.6 Secure Services

API Gateway의 기능중 중요한 역할을 하는 부분이기도 합니다. 주로 인증(Authentication) 과 관련된 기능을 의미합니다. 인증(Authentication)과 인가(Authorization)은 헷갈리지만 차이가 있는 개념입니다.

![Untitled 9](https://user-images.githubusercontent.com/79149004/125185359-676e8980-e25f-11eb-9563-14e296dc5b77.png)

[http://www.opennaru.com/opennaru-blog/jwt-json-web-token-with-microservice/](http://www.opennaru.com/opennaru-blog/jwt-json-web-token-with-microservice/)

기본적으로 인증에 사용되는 방식은 아래와 같은 방법이 존재합니다.

- Basic Authentication
- Key Authentication
- OAuth 2.0 Authentication
- LDAP Authentication Advanced
- OpenID Connect

API Gateway에서 인증은 성공적으로 인증되지 않은 요청에 대해서 서비스로 요청을 전달하지 않습니다.

여러 방법 중에 API Key 인증 방법을 예제로 다루고자 합니다.

### 2.6.1 키 플러그인 등록

![Untitled 10](https://user-images.githubusercontent.com/79149004/125185360-676e8980-e25f-11eb-895c-38277a0ccfad.png)

key-auth의 플러그인을 등록하면, 키 사용자 등록 및 요청 처리를 별도로 해주지 않으면 아래 메시지로 요청에 대한 응답을 거부합니다.

```json
{
  "message": "No API key found in request"
}
```

**요청**

```bash
curl -X POST http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:8001/routes/mocking/plugins \
  --data name=key-auth
```

**응답**

```json
{"protocols":["grpc","grpcs","http","https"],"service":null,"id":"7581a3ae-7107-4361-8e32-c91f316214ff","created_at":1623806947,"route":{"id":"81580cf8-3a6c-4b37-95df-5e810f41b07e"},"enabled":true,"config":{"key_in_body":false,"anonymous":null,"key_names":["apikey"],"hide_credentials":false,"run_on_preflight":true,"key_in_header":true,"key_in_query":true},"name":"key-auth","tags":null,"consumer":null
```

### 2.6.2 키 사용자 등록

![Untitled 11](https://user-images.githubusercontent.com/79149004/125185361-68072000-e25f-11eb-98e2-57e66441af31.png)

**요청**

```bash
curl -i -X POST http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:8001/consumers/ \
  --data username=consumer \
  --data custom_id=consumer
```

**응답**

```json
{
  "created_at": 1623806475,
  "username": "consumer",
  "id": "48fe36d7-b463-466f-a2db-a61c5a6941b7",
  "tags": null,
  "custom_id": "consumer"
}
```

### 2.6.3 API 키 등록

![Untitled 12](https://user-images.githubusercontent.com/79149004/125185362-689fb680-e25f-11eb-8422-04aead57949f.png)

위 내용을 보면 key-auth는 RESTFul resource 구조 상 consumer에 종속되어 관리되는 것을 볼 수 있습니다.

**요청**

```json
curl -i -X POST http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:8001/consumers/consumer/key-auth \
  --data key=apikey
```

**응답**

```json
{
  "created_at": 1623807181,
  "key": "apikey",
  "consumer": { "id": "48fe36d7-b463-466f-a2db-a61c5a6941b7" },
  "id": "4bd5a77c-bcd1-43d4-a738-f5aac2d348ce",
  "tags": null,
  "ttl": null
}
```

### 2.6.4 API 키 반영 테스트

구성된 API Route 하단에 아래와 같은 파라미터로 API Key를 전달할 수 있습니다.

```json
/?apikey=apikey
```

**키 포함되지 않은 요청**

```json
curl -i http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:80/mock
```

**키 포함되지 않은 요청에 대한 응답**

```json
{
  "message": "No API key found in request"
}
```

**키 포함 요청**

```json
curl -i http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:80/mock/?apikey=apikey
```

**키 포함 요청에 대한 응답**

```json
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="https://www.google.com/?apikey=apikey">here</A>.
</BODY></HTML>
```

google.com으로 요청하도록 api를 지정해두었기 때문에 성공적인 응답이 내려오는 것을 알 수 있습니다.

# 2.7 Set Up Intelligent Load Balancing

Load Balancing은 아래의 그림과 같이 같은 요청에 대해 부하를 분산하기 위해 사용됩니다.

![Untitled 13](https://user-images.githubusercontent.com/79149004/125185363-689fb680-e25f-11eb-82df-a7fabbfff57a.png)

Load Balancing은 TCP/IP 레이어에 따라 가능한 기능들이 다른데,
Kubernetes에서 Service에서 Pod로 요청을 나누는 것은 L4 로드벨런서를 사용합니다.

더 앞단에서 URL 요청에 의해 부하를 분산시킬 수 있는 Ingress라 통칭하는 것들은 L7 로드벨런서를 사용하는데, Kong Gateway는 L7 로드밸런서의 기능을 합니다.

### 2.7.1 로드밸런서 구성 및 테스트

![Untitled 14](https://user-images.githubusercontent.com/79149004/125185364-69384d00-e25f-11eb-8ea6-df182e4d2b63.png)

위 내용을 바탕으로 아래처럼 이전에 설정해둔 route 에 대해 google.com과 [naver.com](http://naver.com) 으로 로드벨런싱 하는 과정을 진행해봅니다.

**로드벨런서에 대한 upstream 생성**

```json
curl -X POST http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:8001/upstreams \
  --data name=upstream
```

**서비스에 생성한 upstream 연결**

```json
curl -X PATCH http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:8001/services/example_service \
  --data host='upstream'
```

**로드벨런서 taget 등록**

```json
curl -X POST http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:8001/upstreams/upstream/targets \
  --data target='naver.com:80'

curl -X POST http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com:8001/upstreams/upstream/targets \
  --data target='google.com:80'
```

**로드벨런싱 테스트**

```bash
curl -X GET http://a9644d2f327aa4554813ee01a9b4a1e8-1978321371.ap-northeast-2.elb.amazonaws.com::8000/mock
```

# 3. 정리

본 글을 통해 Kong Admin으로 API를 구성하고, 그와 관련된 다양한 내용들을 살펴보았습니다. 기본적으로 제공해주는 플러그인들은 일반적인 경우를 위해 고려되었기 때문에 API Gateway에 대한 일반적인 이해를 바탕으로 필요한 경우 직접 플러그인을 구성하여 시스템을 설계할 수도 있어 보입니다.

또한 Konga를 이용해 API를 구성하면 직관적으로 기능을 이해할 수 있지만, 모든 기능을 Konga를 통해 확인하기 어려운 부분이 있으므로, 실 서비스에 활용할 목적이라면 Kong Guide 문서를 모두 읽어보시길 권장드립니다.

# 4. 참고자료

[https://github.com/pantsel/konga](https://github.com/pantsel/konga)

[https://docs.konghq.com/getting-started-guide/2.4.x/overview/](https://docs.konghq.com/getting-started-guide/2.4.x/overview/)

[https://docs.konghq.com/getting-started-guide/2.4.x/prepare/#verify-the-kong-gateway-configuration](https://docs.konghq.com/getting-started-guide/2.4.x/prepare/#verify-the-kong-gateway-configuration)

[http://www.opennaru.com/opennaru-blog/jwt-json-web-token-with-microservice/](http://www.opennaru.com/opennaru-blog/jwt-json-web-token-with-microservice/)
