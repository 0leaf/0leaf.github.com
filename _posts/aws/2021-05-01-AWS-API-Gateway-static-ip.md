---
title: AWS API Gateway 고정 IP 만들기 (NLB → VPC endpoint → API Gateway)
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - AWS
tag:
  - API Gateway
  - NLB
  - VPC endpoint
  - static IP
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: API Gateway
article_tag2: 고정 IP
article_tag3: NLB
article_section: section
meta_keywords: API Gateway, 고정 IP, Static IP, NLB, VPC Endpoint
last_modified_at: "2021-05-01 14:33:00 +0800"
---

NLB, VPC endpoint, API Gateway를 활용하여 AWS API Gateway의 IP를 고정 IP로 만드는 과정을 설명합니다.

# 0. 시작하기 전에

API Gateway의 IP가 고정이든 유동이든 큰 신경쓸 필요가 없는 경우가 대부분이긴 합니다.
하지만 회사 보안 정책이나 특정 시스템의 방화벽 허용을 위한 예외 처리를 화이트 리스트로 관리해야 한다면, IP는 아무래도 고정으로 지정되어 있어야 관리하기 편합니다.

현재 글 작성 시점 기준으로 AWS에서 해당 기능을 편리한 방법으로 제공하지 않고 있으며 여러가지 쉽고 어려운 방법들이 존재하는데, 그 중 구조상 제일 괜찮은 것으로 생각되는 아래 구성에 대한 기록을 남깁니다.

Route 53/Domain → NLB → VPC Endpoint → API Gateway(Private)

# 1. 문제의 인식

![image](https://user-images.githubusercontent.com/79149004/116772474-526cc180-aa8a-11eb-8956-9402d5665828.png)

[https://google.com](https://google.com으로) 으로 GET 요청을 날리는 간단한 API 를 하나 정의하고 배포해보도록 하겠습니다.

그 결과 [https://344i1vresf.execute-api.ap-northeast-2.amazonaws.com/test](https://344i1vresf.execute-api.ap-northeast-2.amazonaws.com/test) API주소를 얻었습니다.

**위 주소는 글 작성 이후 삭제될 예정이므로 호출하셔도 올바른 응답을 얻을 수 없습니다.**

문제의 현상을 보기 위함이니 참고용으로 보시면 될 것 같습니다.

**요청**

```json
curl -X GET https://344i1vresf.execute-api.ap-northeast-2.amazonaws.com/test
```

**응답**

```json
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="https://www.google.com/">here</A>.
</BODY></HTML>
```

응답 결과가 301로 떨어지는걸로 봐서 API Gateway는 잘 연동되었다는 것을 알 수 있습니다.

이제 테스트 환경은 끝났고,

[https://344i1vresf.execute-api.ap-northeast-2.amazonaws.com](https://344i1vresf.execute-api.ap-northeast-2.amazonaws.com) 주소의 실제 IP를 확인해보겠습니다.

**nslookup** 혹은 **dig**을 이용하여 확인합니다.

```bash
$dig [344i1vresf.execute-api.ap-northeast-2.amazonaws.com](http://344i1vresf.execute-api.ap-northeast-2.amazonaws.com/)
$nslookup [344i1vresf.execute-api.ap-northeast-2.amazonaws.com](http://344i1vresf.execute-api.ap-northeast-2.amazonaws.com/)
```

```json
[1회차 요청]
nslookup 344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Server:		192.168.10.1
Address:	192.168.10.1#53

Non-authoritative answer:
Name:	344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Address: 3.35.86.48
Name:	344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Address: 52.78.233.230

---------------

[2회차 요청]
nslookup 344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Server:		192.168.10.1
Address:	192.168.10.1#53

Non-authoritative answer:
Name:	344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Address: 3.34.120.247
Name:	344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Address: 52.78.33.158

---------------

[3회차 요청]
nslookup 344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Server:		192.168.10.1
Address:	192.168.10.1#53

Non-authoritative answer:
Name:	344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Address: 3.36.158.122
Name:	344i1vresf.execute-api.ap-northeast-2.amazonaws.com
Address: 3.36.30.67
```

위 결과의 **Non-authoritative answer 부분**을 보시면 응답 서버의 IP가 계속 바뀌어 내려오는 것을 확인할 수 있습니다. 따라서 AWS API Gateway는 고정 IP로 사용자들에게 API 서비스를 제공하지 않는다는 것을 확인할 수 있습니다.

# 2. Building Block

![image](https://user-images.githubusercontent.com/79149004/116772480-5993cf80-aa8a-11eb-9041-5b3cd98b4926.png)

NLB와 API Gateway의 위치가 위 그림과 정확히 일치하지 않지만 전체적인 동작의 이해를 돕기 위해 Subnet 구성을 통합하고 그 안에 블록을 포함시켰습니다.

실제 시스템을 구성하게 될 순서는 **API Gateway → VPC Endpoint → NLB → DNS 연결** 순으로 위 그림 기준 **오른쪽에서 왼쪽**으로 구성합니다.

# 3. 구성

VPC 구성은 아래와 같이 이미 완료되어있는 것을 가정하며 본 글에서 VPC 구성 방법은 다루지 않으나, 이후 다른 글에서 다루어 보도록 하겠습니다.

![image](https://user-images.githubusercontent.com/79149004/116772484-5ef11a00-aa8a-11eb-8838-71a5705ab29d.png)

## 3.1. API Gateway 생성

**API Gateway → API → API 생성**

![image](https://user-images.githubusercontent.com/79149004/116772486-644e6480-aa8a-11eb-8977-1951b7749ae2.png)

위 화면에서 네번째 항목인 **REST API 프라이빗** 을 선택해 API 를 생성합니다.

![image](https://user-images.githubusercontent.com/79149004/116772488-69131880-aa8a-11eb-91aa-bc41029b3a55.png)

엔드포인트 유형의 설명을 보면 REST API 프라이빗 으로 만든 API 는 **API Gateway용 VPC 엔드포인트를 통해서만 엑세스 할 수 있다**는 것을 주의깊게 보셔야 합니다. 외부에서 직접 호출이 불가능하며 VPC 엔드포인트와 연동이 필요합니다.

![image](https://user-images.githubusercontent.com/79149004/116772492-6fa19000-aa8a-11eb-992a-2c56ee985d5d.png)

문제의 인식 부분에서 사용했던 테스트용 Get Method를 위 내용과 같이 정의한 뒤에 배포합니다.

## 3.2. VPC Endpoint 생성

![image](https://user-images.githubusercontent.com/79149004/116772498-77f9cb00-aa8a-11eb-8bf4-1cee49a96cfb.png)

서비스 이름은 execute-api가 포함된 것을 선택합니다.

원하는 VPC를 선택한 뒤 서브넷을 선택할때 API Gateway를 통해 private 영역에 있는 API를 호출하려고 하면 private 영역을 선택해야 합니다. 여기서는 private 영역을 선택해줍니다.

보안 그룹은 필요한 경우 원하는 보안 그룹을 지정합니다.

![image](https://user-images.githubusercontent.com/79149004/116772501-7d571580-aa8a-11eb-9ffc-ab82e12454ba.png)

VPC Endpoint를 생성하고 나면 위 화면과 같이 private zone에 해당하는 ip가 임의로 할당된 것을 볼 수 있습니다.

## 3.3. Network Load Balancer 생성 및 Elastic IP 연결

### 3.3.1. Elastic IP 생성

**네트워크 및 보안 → 탄력적 IP → 탄력적 IP 주소 할당**

NLB 생성 과정에서 탄력적 IP 주소를 사용할 수 있도록 지정하는 화면이 있기 때문에, 미리 만들어둡니다. 해당 과정에서는 a zone, c zone에서 사용할 두개의 static ip를 생성합니다.

### 3.3.2. Network Load Balancer 생성

**EC2 → 로드 밸런싱 → 로드밸런서 → Load Balancer 생성**

![image](https://user-images.githubusercontent.com/79149004/116772504-821bc980-aa8a-11eb-99fa-c056a675dbd9.png)

Network Load Balancer를 선택하여 생성합니다.

**3.3.2.1. 기본 설정**

![image](https://user-images.githubusercontent.com/79149004/116772510-8647e700-aa8a-11eb-8a27-2319e53942be.png)

**3.3.2.2. Network mapping**

![image](https://user-images.githubusercontent.com/79149004/116772516-8e078b80-aa8a-11eb-9c03-a192c9778eb5.png)

**3.3.2.3. Listeners and routing**

![image](https://user-images.githubusercontent.com/79149004/116772518-92cc3f80-aa8a-11eb-8f7e-d19ba5fe76b2.png)

위 화면에서 **Create target group** 을 선택하여 대상 그룹을 생성하고 VPC Endpoint로 routing 할 IP 들을 지정해주어야 합니다.

**3.3.2.4. Traget group**

![image](https://user-images.githubusercontent.com/79149004/116772526-a5df0f80-aa8a-11eb-9ebf-dfb0a16a5998.png)

위 화면은 대상 그룹의 생성 화면인데 특별한 내용 없이 저정하고 다음으로 넘어갑니다.

![image](https://user-images.githubusercontent.com/79149004/116772529-ac6d8700-aa8a-11eb-8f1a-2e98b0da82c0.png)

위 화면과 같이 IP 부분에 **VPC Endpoint 때 자동으로 생성되었던 IP**들 (a zone, c zone 모두)을 등록해줍니다.

이후 NLB 생성을 완료해줍니다.

![image](https://user-images.githubusercontent.com/79149004/116772531-b1cad180-aa8a-11eb-8b57-972c73061bae.png)

이후 대상 그룹에서 health check가 healthy(green)으로 불이 들어오면
NLB → StaticIP → 대상그룹 → VPC End Point 까지 연결이 잘 되었다고 생각할 수 있습니다.

## 3.4. 동작 확인

```bash
curl -k -H "Host : {api gateway 주소}" https://{nlb 주소}/{api gateway stage}
```

사용자 지정 도메인 이름을 연동하기 전에 NLB 주소로 API Gateway를 호출해보고자 한다면 위의 방식으로 테스트 해볼 수 있습니다.

여기서 드는 의문점은 VPC Endpoint와 API Gateway를 연결한 적이 없이 없는데 어떻게 호출할 수 있지 라는 생각이 들 수 있습니다.

직접 연결하지 않아도 API Gateway를 호출할 수 있는데 NLB를 통해 호출해야 하는 과정을 위해 Header의 Host 필드에 요청할 API Gateway 주소를 지정해야 합니다.

이 다음 단계에서 도메인과 API Gateway를 연결하게 되면 도메인을 통해 헤더 없이 직접 호출할 수 있게 됩니다.

## 3.5. 사용자 지정 도메인 이름

![image](https://user-images.githubusercontent.com/79149004/116772538-b7281c00-aa8a-11eb-8b25-d6fde419ac0e.png)

위 화면은 API Gateway 화면에서 왼쪽에 **위치한 사용자 지정 도메인 이름** 을 선택했을때 나오는 화면이며,

도메인과 관련된 내용을 추가하여 생성하고 생성된 항목을 선택하면 API Gateway의 배포된 Phase와 연동할 수 있습니다.

해당 도메인 주소에 NLB 주소의 CNAME을 Route53에도 추가해줍니다.

이 과정을 끝내면 생성한 도메인으로 일반적인 방식으로 API 요청을 할 수 있습니다.

# 4. 정리

위 과정을 진행하고 나면 NLB에 지정한 도메인을 dig 혹은 nslookup을 통해 요청해보면 nlb 생성 시 지정한 Elastic IP로 일관된 IP로부터의 응답을 내려주는 것을 볼 수 있습니다.

이후 AWS에서 API Gateway의 IP를 고정으로 내려주는 기능이 추가될 지 모르겠으나 현재로서는 해당 구조가 제일 문제가 발생하지 않을 구조라 판단하여 조사한 자료들을 바탕으로 구성한 기록을 남깁니다.

# 참고자료

[https://zenliu.medium.com/how-to-assign-elastic-ip-to-amazon-api-gateway-ddbee9146bec](https://zenliu.medium.com/how-to-assign-elastic-ip-to-amazon-api-gateway-ddbee9146bec)

[https://medium.com/opseco-technologies/assign-fixed-ip-to-aws-api-gateway-fb72507a2883](https://medium.com/opseco-technologies/assign-fixed-ip-to-aws-api-gateway-fb72507a2883)
