---
title: Kong Gateway 4. Kong Auth Plugin 연동하기
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Kong
tag:
  - Kong, Plugin, Auth
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: Kong
article_tag2: Plugin
article_tag3: Auth
article_section: section
meta_keywords: Kong, Kong Admin, Auth, Plugin
last_modified_at: "2021-09-18 16:57:00 +0800"
---

Kong, Plugin, Authorization에 대한 설명 및 구성 과정을 설명합니다.

# Kong Gateway #4 Kong Auth Plugin 연동

# 0. 들어가기 전에

kong gateway는 기본적으로 인증 관련된 플러그인들을 기본적으로 제공합니다. 인증 및 인가에 대해서 간단히 알아보고 kong이 제공하는 몇가지 인증 플러그인들을 사용해보고 그 과정을 기술해보려고 합니다. consumer나 upstream 등을 상세하게 설정할 수 있으나, 본 글에서는 사용법과 과정을 살펴보는 것이 주된 목적이므로 자세한 과정을 생략함을 말씀드립니다.

# 1. Authentication(인증) vs Authorization(인가)

인증과 인가에 대한 용어는 많이들 헷갈리곤 합니다. 주로 인증을 이야기할때 인가를 포함하여 이야기하는 경우가 많은 것 같습니다. 따라서 조금 헷갈리시는 분들은 [링크](https://www.okta.com/identity-101/authentication-vs-authorization/) 글을 읽어보시면 이해하시는데 많은 도움이 될 것 같습니다.

이 글에서는 간단한 이해를 돕기 위해 짧은 설명을 덧붙이도록 하겠습니다.

![Untitled](https://user-images.githubusercontent.com/6061207/133881195-dea0b835-2785-4c57-a36c-4a2d8cbeab79.png){: .align-center width="500"}

Authentication(인증)은 회원 로그인과 같은 절차를 통해 해당 사용자에 대한 신원 확인을 하는 과정을 의미합니다. 보통 Google의 로그인 화면과 같이 사용자의 정보를 바탕으로 접근 가능한 사용자인지를 인증합니다.

![Untitled 1](https://user-images.githubusercontent.com/6061207/133881199-79d08c02-87a1-4600-a48d-d0fe8443fef6.png){: .align-center width="500"}

Authorization(인가)은 인증 과정에서 해당  어느 기능들을 사용할 수 있는지에 대한 권한을 확인하고 인가하는 과정을 의미합니다. 

# 2. 인증 및 인가 과정

여러 인증 방식중에 풍부한 스펙을 가진 OAuth2.0을 설명하기 위한 [글](https://developer.okta.com/blog/2017/06/21/what-the-heck-is-oauth)에 포함된 그림 중 일부를 발췌해 설명하도록 하겠습니다. 참고로 OAuth2.0은 여러 grant type에 따라 인증 절차가 다양합니다. 이에 대해서는 자세히 다루지 않고 생략하며, 조금 추상적인 단계로 설명을 이어나가보도록 하겠습니다.

![Untitled 2](https://user-images.githubusercontent.com/6061207/133881404-cacb843d-d0d2-4ca4-ae3a-4c3069bf81e9.png){: .align-center width="500"}

최종 목적은 Client가 ResourceServer에 접근하는 것이 목표이며, 이를 위해 Resource Server에 접근을 하기 위한 필수 조건인 token을 발급받는 과정이 필요합니다.

- 1,2번 과정을 통해 client는 로그인 혹은 사용자 정보를 통해 인증을 진행합니다. [인증]
- 3번 과정을 통해 인증이 성공할 경우, ResourceOwner(사용자) 에게 특정 권한에 허용해도 괜찮은지 허락을 구합니다. [인가]
- 4번 과정으로 client에게 Resource에 접근 가능한 토큰을 부여합니다.

위 흐름은 대략적인 내용이고, 인증 유형에 따라 달라지는 내용이라고 할 수 있습니다. 하지만 추상화된 단계로 살펴보면 client는 인증 서버에게 "로그인" 과 같은 절차를 통해 사용자 정보를 전달하고 유효한 사용자 정보라면 

해당 사용자가 어떤 리소스에 접근 가능한지를 인가하는 과정을 거쳐 토큰을 받습니다.

그리고 그 토큰은 Resource Server에 접근 가능하기 위한 필수 요건이 됩니다.

이 과정은 OAuth에 대한 인증/인가 과정이며, 인증 유형에 따라 조금씩 다를 수 있다는 것을 다시 한번 말씀드립니다.

이후 살펴볼 플러그인 테스트는 kong에 사용자 인증 정보를 미리 등록시켜놓고 (ID/PW, API Key 등) API 서비스와 연동시키는 과정과 clinet가 해당 인증 정보를 바탕으로 요청하는 방법에 대해서 기술하려고 합니다.

# 3. 인증 플러그인 종류

![Untitled 3](https://user-images.githubusercontent.com/6061207/133881410-fe442a45-b527-45ee-9f67-02e80509e3a5.png){: .align-center width="500"}

위 사진은 konga 에서 캡쳐한 사진으로 kong에서 기본적으로 제공하는 Authentication 플러그인들을 보여줍니다. 이 중에 몇가지를 선택하여 사용하는 과정을 다뤄보겠습니다.

더 많은 플러그인들은 [공식 홈페이지 플러그인 리스트](https://docs.konghq.com/hub/) 에서 확인 가능하며, 이후 다른 글에서 custom plugin 등을 구성하고 연동하는 과정도 다뤄보도록 하겠습니다.

# 4. 기본 제공 플러그인 연동

## 4.1. 사용할 예제 및 준비

![Untitled 4](https://user-images.githubusercontent.com/6061207/133881413-e0b98698-2212-41cb-b670-b645c6b34c8a.png){: .align-center width="500"}

이전 글에서도 사용했던 이미지를 가져왔습니다. 보통은 api gateway 내부의 upstream 서버로 요청하는 시나리오가 적당하지만, 기능을 테스트 하는것에 목적을 두기 위해 쉬운 예제로 google.com, naver.com. daum.net으로 요청하는 API를 두고 설명해보도록 하겠습니다.

[konga를 통해 API Routing 구성 글](https://0leaf.github.io/kong/Kong-Gateway-2-Kong-on-kubernetes-(Kong,Konga)/#6-api-%EC%84%A4%EC%A0%95-%ED%85%8C%EC%8A%A4%ED%8A%B8) 를 참고하시면 기본 설정을 마치실 수 있습니다.

또한 [Kong admin API로도 구성](https://0leaf.github.io/kong/Kong-Gateway-3-Kong-Admin-%EC%9C%BC%EB%A1%9C-API-%EA%B5%AC%EC%84%B1%ED%95%98%EA%B8%B0/)할 수 있지만, 이해를 돕기 위해 Konga 툴로 이용해 진행하는 과정을 기술하겠습니다.

아래 절차들은 konga 화면에서 Routes - Plugins 화면에서 플러그인들을 추가할 수 있습니다.

![Untitled 5](https://user-images.githubusercontent.com/6061207/133881415-bb981972-5d81-47f2-ba17-6fa49cc36bd0.png){: .align-center width="500"}

또한 인증 과정은 앞서 말씀드린 내용처럼 요청자의 신원을 확인할 수 있어야 하는데, 예상되는 요청자를 Consumer를 통해 등록할 수 있습니다. 예를들어 G 라는 Consumer를 등록해놓으면, G만 Google 에 요청할 수 있도록 token을 발급해주는 과정을 말합니다.

![Untitled 6](https://user-images.githubusercontent.com/6061207/133881417-41bd6a7b-c9dc-418f-945b-cfa848fbe229.png){: .align-center width="500"}

위 사진처럼 G, K, N Consumer를 미리 구성해둡니다.

![Untitled 7](https://user-images.githubusercontent.com/6061207/133881419-78410fce-2cfc-4c18-a386-d401ecb68a63.png)


생성 후 해당 Consumer에게 적용할 Credentials를 설정할 수 있는데, 이 글에선 Basic, API Keys, HMAC 을 각각 Naver, Kakao, Google에 적용해보도록 할 예정입니다.

## 4.2. 인증 유형별 요청 방법

인증 플러그인들을 원하는 서비스에 붙일 경우 client가 요청하는 방법들이 각각 다릅니다. 이후 단계를 진행하기에 앞서 각 인증별로 정보를 전달하는 방법을 참고하시면 좋을 것 같습니다.

### [basic-auth](https://docs.konghq.com/hub/kong-inc/basic-auth/)

header 방식 - ex) Authorization: Basic dGVzdDphc2Rm

[basic auth header generator](https://www.blitter.se/utils/basic-authentication-header-generator) 

### [key-auth](https://docs.konghq.com/hub/kong-inc/key-auth-enc/#upstream-headers)

query param 방식 등 - ex) ?apikey=dGVzdDphc2Rm

### [hmac-auth](https://docs.konghq.com/hub/kong-inc/hmac-auth)

header 방식 - ex) Authorization : hmac username="hmac-test",algorithm="hmac-sha1",headers="X-Date",signature="089b8fcf36ce5bae9ccea9ad588609964a640f2e"

[hmac auth header generator](https://www.freeformatter.com/hmac-generator.html)

### [jwt](https://docs.konghq.com/hub/kong-inc/jwt)

header 방식 - ex) Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9....

[jwt auth header generator](https://jwt.io/)

### [oauth2](https://docs.konghq.com/hub/kong-inc/oauth2)

header 및 query param 방식

[https://konghq.com/blog/kong-gateway-oauth2/](https://konghq.com/blog/kong-gateway-oauth2/)

## 4.3 Basic Auth 테스트

아래 절차대로 N 이라는 consumer가 Naver라는 서비스에 요청하기 위한 기본 설정을 하도록 하겠습니다.

Consumers → N → Credentials → Basic → Create Credentials

![Untitled 8](https://user-images.githubusercontent.com/6061207/133881420-5cdc5425-b013-4c96-b3ec-2c6f7a76cdb6.png){: .align-center width="500"}

위와 같이 입력해줍니다.

![Untitled 9](https://user-images.githubusercontent.com/6061207/133881421-e7f7deeb-2b67-4311-a902-e27843378721.png){: .align-center width="500"}

Naver service에 가서 플러그인을 설정해주고, Eligible consumers 도 확인해줍니다.

![Untitled 10](https://user-images.githubusercontent.com/6061207/133881422-74088ec8-b2cb-49af-8ee4-84a743ba4399.png){: .align-center width="500"}

![Untitled 11](https://user-images.githubusercontent.com/6061207/133881423-207b3d84-233d-47e9-a5f1-873e6d4e59ce.png){: .align-center width="500"}

이렇게 설정된 API로 요청해보도록 합니다.

요청

```bash
curl {kong address}/naver
```

응답

```bash
{
  "message":"Unauthorized"
}
```

[basic auth header generator](https://www.blitter.se/utils/basic-authentication-header-generator)  사이트에서 Authorization 헤더에 포함시킬 정보를 생성해보도록 합니다.

![Untitled 12](https://user-images.githubusercontent.com/6061207/133881425-67cbe733-0aca-4a56-870f-c7594d8edaf1.png)

요청

```bash
curl {kong address}/naver -H "Authorization: Basic bmF2ZXItdGVzdDoxMjM0"
```

응답

```bash
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center> NWS </center>
</body>
</html>
```

## 4.4 API Key 테스트

아래 절차대로 K 이라는 consumer가 Kakao라는 서비스에 요청하기 위한 기본 설정을 하도록 하겠습니다.

Consumers → K → Credentials → API Keys→ Create Credentials

![Untitled 13](https://user-images.githubusercontent.com/6061207/133881428-1f3393b1-ca29-460d-a895-10bd6e533ee9.png){: .align-center width="500"}

![Untitled 14](https://user-images.githubusercontent.com/6061207/133881429-a45d4805-35cf-4646-b39e-86dac958cc59.png){: .align-center width="500"}

![Untitled 15](https://user-images.githubusercontent.com/6061207/133881430-d20abd0d-41fb-4715-b600-2198b3d5beac.png){: .align-center width="500"}

플러그인을 붙일때 아무 값도 입력하지 않으면 다음 정보가 기본으로 입력됩니다.

![Untitled 16](https://user-images.githubusercontent.com/6061207/133881431-4fdbcf7e-d5e8-4afd-8756-796ec241ce52.png){: .align-center width="500"}

![Untitled 17](https://user-images.githubusercontent.com/6061207/133881432-c33c18c6-ff18-4bf1-b97a-0e6d69bce316.png){: .align-center width="500"}

요청

```bash
curl {kong address}/kakao
```

응답

```bash
{
  "message":"No API key found in request"
}
```

요청

```bash
curl {kong address}/kakao?apikey=test-api-key
```

응답

```bash
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>302 Found</title>
</head><body>
<h1>Found</h1>
<p>The document has moved <a href="http://www.daum.net/?apikey=test-api-key">here</a>.</p>
</body></html>
```

## 4.5 HMAC 테스트

아래 절차대로 G 이라는 consumer가 Google라는 서비스에 요청하기 위한 기본 설정을 하도록 하겠습니다.

Consumers → G → Credentials → HMAC → Create Credentials

![Untitled 18](https://user-images.githubusercontent.com/6061207/133881433-f9065095-0aca-49eb-9993-d660edb4d664.png){: .align-center width="500"}

![Untitled 19](https://user-images.githubusercontent.com/6061207/133881434-065825c6-c4e1-4e27-86d6-42c627c91b71.png){: .align-center width="500"}
![Untitled 20](https://user-images.githubusercontent.com/6061207/133881435-61fd7500-f966-4349-afc4-a7c141183e25.png){: .align-center width="500"}

플러그인을 붙일때 아무 값도 입력하지 않으면 다음 정보가 기본으로 입력됩니다.

![Untitled 21](https://user-images.githubusercontent.com/6061207/133881436-f3ff9735-6d6e-49d1-9f42-a348da5e0bc9.png){: .align-center width="500"}

![Untitled 22](https://user-images.githubusercontent.com/6061207/133881437-0ba0e8fa-2ba5-46ae-8fd9-a009c8e96eb7.png){: .align-center width="500"}

 [hmac auth header generator](https://www.freeformatter.com/hmac-generator.html) 사이트에서 Authorization 헤더에 포함시킬 정보를 생성해보도록 합니다.

![Untitled 23](https://user-images.githubusercontent.com/6061207/133881439-6161c12e-092a-4219-bd53-2cb65928a19c.png){: .align-center width="500"}

요청

```bash
curl {kong address}/google
```

응답

```bash
{
  "message":"Unauthorized"
}
```

요청

```bash
curl {kong address}/google -H 'Authorization : hmac username="hmac-test",algorithm="hmac-sha1",headers="X-Date",signature="089b8fcf36ce5bae9ccea9ad588609964a640f2e"'
```

응답

```bash
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="https://www.google.com/">here</A>.
</BODY></HTML>
```

# 5. 정리

인증/인가 과정은 OpenAPI로 구성하거나 client들에게 제한된 기능을 제공해야 할 경우 필수적인 요소입니다.

또한 Resource Server나 API Server에 접근 가능한 token/API Key 등이 유출되면 비용을 지불하지 않고 요청하거나 예상되지 않은 경로 등으로 API를 요청할 수 있게 되어 보안상 문제가 발생합니다.

따라서 보다 안정된 유형의 인증 서비스를 제공하려고 한다면 고정된 API Key 등으로 client에게 제공하기 보다, 토큰의 발급/갱신/삭제 등을 처리하는 인증/인가 기능이 필요합니다.

기회가 된다면 다음 글에서 custom plugin 구성과 안정화된 인증을 적용해보는 과정을 기술해보도록 하겠습니다.

# 6. 참고

[https://howtogapps.com/google-script-authorization-review-and-accept-the-permission-guide/](https://howtogapps.com/google-script-authorization-review-and-accept-the-permission-guide/)

[https://developer.okta.com/blog/2017/06/21/what-the-heck-is-oauth](https://developer.okta.com/blog/2017/06/21/what-the-heck-is-oauth)

[https://docs.konghq.com/hub/](https://docs.konghq.com/hub/)