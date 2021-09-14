---
title: click log system 구성하기 (API Gateway → Kinesis → S3)
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
  - Kinesis
  - S3
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: clicklog
article_tag2: API Gateway
article_tag3: kinesis
article_section: section
meta_keywords: click log, API Gateway, Kinesis, S3, kinesis data stream, kinesis data firehose
last_modified_at: "2021-05-01 15:23:00 +0800"
---

lambda 구성 없이 API Gateway, Kinesis Data Stream, Kinesis Data Firehose, S3로 click log 시스템을 구성하는 과정을 설명합니다.

# 0. 시작하기 전에

사용자가 application에서 특정 action을 했을 때 서버에 남을 api 로그와 별개로 **사용자 행동과 관련된 로그를 별도로 저장하고 싶은 경우, 임의의 body 데이터를 의도한 공간에 저장하기 위한 경우**의 시스템 구성에 대해 기록합니다.

# 1. Building block

![image](https://user-images.githubusercontent.com/79149004/116773272-826a9380-aa8f-11eb-9201-8c24e6214a1d.png)

다른 글들을 보면 kinesis 중간에 lambda가 handing 해주는 부분이 있는데 lambda 과정을 생략하는 방법을 다루고자 합니다.

본 글에서는 API Gateway를 통해 직접 kinesis data streams로 데이터를 전달하여 kinesis data firehose를 통해 S3로 stream data를 이관하는 방법을 기술하고자 합니다.

# 2. aws console로 구성하기

aws console은 aws 업데이트 마다 화면 구성이 및 기능들이 달라지겠지만, 직관적으로 작업할 수 있는 장점이 있기에 진행했던 내용을 정리하여 기술합니다.

## 2.1. IAM role 생성

### 2.1.1. 정책(Policy) 생성

**Identity and Access Management(IAM) → 정책 → 정책 생성**
![image](https://user-images.githubusercontent.com/79149004/116773273-88607480-aa8f-11eb-90f3-1680822db4b1.png)

위 화면에서 필요한 액세스 권한만을 부여하는 것이 맞지만 지금 과정은 테스트 과정이므로 모든 권한을 허용하는 것으로 진행해보도록 합니다.

위와 같이 정책 오류에 대한 메세지는 **리소스에서 특정 혹은 모든 리소스**에서 문제되는 부분을 해결할 수 있습니다.

[태그 추가는 건너 뛰도록 합니다.]

![image](https://user-images.githubusercontent.com/79149004/116773276-8e565580-aa8f-11eb-9c7b-6c5131c095fb.png)

마지막으로 정책에 대한 이름을 지정하고 생성합니다.

### 2.1.2. 역할(Role) 생성

**Identity and Access Management(IAM) → 역할 → 역할 생성**
![image](https://user-images.githubusercontent.com/79149004/116773278-93b3a000-aa8f-11eb-8225-8c2ff8fef26c.png)

신뢰할 수 있는 유형의 개체를 선택합니다. 사용할 서비스에서 이 역할을 접근할 때 신뢰성을 보장하기 위해 선택합니다. 여기서는 API Gateway에서 역할을 사용할 것이므로 API Gateway를 선택합니다.

이후에 신뢰할 수 있는 서비스들을 json으로 더 추가할 수 있습니다. **만약 신뢰할 수 있는 서비스에 등록되지 않은 서비스에서 해당 권한으로 요청하게 되면 permission error가 발생**하게 됩니다.

![image](https://user-images.githubusercontent.com/79149004/116773285-99a98100-aa8f-11eb-94f0-c00ea5ae8cd0.png)

위 화면에서 보이는 정책이 CloudWatchLog 밖에 없을 수 있는데 일단 무시하고 생성한 뒤 이후에 정책을 연결 할 수 있습니다.

저는 위 화면처럼 **권한 경계를 사용하여 최대 role개의 권한 제어**를 선택하고 만들어둔 정책을 선택했는데 필수는 아닙니다.

![image](https://user-images.githubusercontent.com/79149004/116773292-9f06cb80-aa8f-11eb-8ecf-e1b7dbdd452b.png)

마지막으로 역할에 대한 이름을 지정하고 생성합니다. 역할 설명은 원하는 내용으로 수정 변경합니다.

![image](https://user-images.githubusercontent.com/79149004/116773294-a3cb7f80-aa8f-11eb-8c74-09c4626e49ec.png)

역할 생성이 완료되면 **역할 ARN**을 이후 Gateway API 진행 과정에서 사용하므로 별도로 메모해둡니다.

![image](https://user-images.githubusercontent.com/79149004/116773299-a7f79d00-aa8f-11eb-85ea-52882f54a8d5.png)

또한 **정책 연결**을 통해 생성한 정책을 역할과 연결해 줍니다.

## 2.2. Kinesis data streams 생성

**Amazon Kinesis → 데이터 스트림 → 데이터 스트림 생성**

![image](https://user-images.githubusercontent.com/79149004/116773303-ac23ba80-aa8f-11eb-8e90-ace03695d932.png)

테스트로 생성하는 목적이므로 샤드는 1개로 설정합니다. 샤드의 수가 많을 수록 허용하는 요청수가 늘어나게 됩니다. 이후 필요한 서비스의 목표에 따라 설정하도록 합니다.

## 2.3. API Gateway

**API Gateway → API → API 생성**

### 2.3.1. API Gateway 생성

![image](https://user-images.githubusercontent.com/79149004/116773307-b2b23200-aa8f-11eb-9183-77d66574436b.png)

**REST API**를 선택하여 구축합니다.

이 [링크 글](https://aws.amazon.com/ko/blogs/compute/announcing-http-apis-for-amazon-api-gateway/)에 따르면, 아래와 같이 HTTP API가 기존의 REST API 보다 더 많은 기능, 더 낮은 지연 시간, 더 낮은 비용 을 위해서 추가된 기능이라고 하는데, 여기서는 kinesis를 구성하기 위해 **REST API**를 선택합니다.

```
With HTTP APIs, we have reduced request pricing to $1.00/million requests for the first 300 million requests, and $0.90/million for all requests after that. Most customers will see an average cost saving up to 70%, when compared to API Gateway REST APIs. In addition, you will see significant performance improvements in the API Gateway service overhead.
```

![image](https://user-images.githubusercontent.com/79149004/116773316-b8a81300-aa8f-11eb-941e-6fce42d11af8.png)
위와 같이 이름을 지정하고 생성합니다.

다음의 공식 가이드 문서에서 말하고 있는 기능들 중에 3번의 **PutRecord**를 api gateway와 연동하려고 합니다. 다른 기능들이 필요한 경우 본 글을 참고하여 [가이드 문서](https://docs.aws.amazon.com/ko_kr/apigateway/latest/developerguide/integrating-api-with-aws-services-kinesis.html)를 따라 진행하시길 권장드립니다.

1. Kinesis의 `ListStreams` 작업
2. `CreateStream`, `DescribeStream` 또는 `DeleteStream` 작업
3. Kinesis의 `GetRecords` 또는 `PutRecords`(`PutRecord` 포함) 작업

위 기능에 대한 가이드문서의 리소스 구성은 다음과 같습니다

- API의 `/streams` 리소스에 HTTP GET 메서드를 노출하고 메서드를 Kinesis의 [ListStreams](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_ListStreams.html) 작업과 통합하여 호출자 계정의 스트림을 나열합니다.
- API의 `/streams/{stream-name}` 리소스에 HTTP POST 메서드를 노출하고 메서드를 Kinesis의 [CreateStream](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_CreateStream.html) 작업과 통합하여 호출자 계정에서 명명된 스트림을 생성합니다.
- API의 `/streams/{stream-name}` 리소스에 HTTP GET 메서드를 노출하고 메서드를 Kinesis의 [DescribeStream](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_DescribeStream.html) 작업과 통합하여 호출자 계정에서 명명된 스트림을 설명합니다.
- API의 `/streams/{stream-name}` 리소스에 HTTP DELETE 메서드를 노출하고 메서드를 Kinesis의 [DeleteStream](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_DeleteStream.html) 작업과 통합하여 호출자 계정에서 스트림을 삭제합니다.
- API의 `/streams/{stream-name}/record` 리소스에 HTTP PUT 메서드를 노출하고 메서드를 Kinesis의 [PutRecord](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecord.html) 작업과 통합합니다. 그러면 클라이언트가 단일 데이터 레코드를 명명된 스트림에 추가할 수 있습니다.
- API의 `/streams/{stream-name}/records` 리소스에 HTTP PUT 메서드를 노출하고 메서드를 Kinesis의 [PutRecords](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecords.html) 작업과 통합합니다. 그러면 클라이언트가 데이터 레코드 목록을 명명된 스트림에 추가할 수 있습니다.
- API의 `/streams/{stream-name}/records` 리소스에 HTTP GET 메서드를 노출하고 메서드를 Kinesis의 [GetRecords](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_GetRecords.html) 작업과 통합합니다. 그러면 클라이언트가 지정된 샤드 반복기를 사용하여 명명된 스트림에 데이터 레코드를 나열할 수 있습니다. 샤드 반복기는 순차적으로 데이터 레코드 읽기를 시작할 샤드 위치를 지정합니다.
- API의 `/streams/{stream-name}/sharditerator` 리소스에 HTTP GET 메서드를 노출하고 메서드를 Kinesis의 [GetShardIterator](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_GetShardIterator.html) 작업과 통합합니다. 이 헬퍼 메서드는 Kinesis의 `ListStreams` 작업에 제공되어야 합니다.

위 가이드 문서는 RESTful 한 구성으로 stream을 지정하여 CRUD 할 수 있도록 되어있는데, 여기서는 stream 이름을 지정하여 PutRecords 할 수 있는 기능을 연동 해보겠습니다.

### 2.3.2. Resource 구성

![image](https://user-images.githubusercontent.com/79149004/116773324-bd6cc700-aa8f-11eb-91f8-891653e40ba3.png)

위 화면과 같이 리소스를 구성해 줍니다. 스트림을 직접 만든 kinesis로 지정할 것이기 때문에 가이드 문서에 나와 있는 {stream-name} 부분의 리소스 구성은 생략하도록 합니다.

### 2.3.3. Method 구성

Method를 생성하고 선택하면 아래 화면이 나오는데, 메서드 요청과 통합 요청을 각각 선택하여 다음의 설정들을 진행한다.

![image](https://user-images.githubusercontent.com/79149004/116773325-c2317b00-aa8f-11eb-8e48-8f3c17a7d9dc.png)

**2.3.3.1. PUT - 메서드 요청**

![image](https://user-images.githubusercontent.com/79149004/116773331-c9f11f80-aa8f-11eb-8270-0e41114e0610.png)

HTTP 메서드는 POST 입니다. 가이드 문서에 따르면 아래와 같이 언급하고 있습니다.

리소스에 HTTP PUT 메서드를 노출하고 메서드를 Kinesis의 PutRecord작업과 통합합니다. 그러면 클라이언트가 단일 데이터 레코드를 명명된 스트림에 추가할 수 있습니다.

API Gateway로 바깥으로 제공하는 method는 RESTful의 의미상 PUT으로, 내부적인 kinesis 동작을 위한 요청 method는 [PutRecord 문서](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecord.html)를 보면 POST로 전달하는 것을 볼 수 있습니다.

**2.3.3.2. PUT - 통합 요청**

![image](https://user-images.githubusercontent.com/79149004/116773333-ceb5d380-aa8f-11eb-8232-17f25efeb0d4.png)

매핑 템플릿 항목을 선택하고, **Content-Type에 application/json을 추가한 뒤 템플릿 내용에 아래 정보를 저장** 합니다.

어떤 stream에 요청할지에 대한 정보를 담고 있으며 **KinesisDataStreamName** 에는 생성한 stream의 이름을 지정해줍니다.

```json
{
  "StreamName": KinesisDataStreamName,
  "Data": "$util.base64Encode($input.body)",
  "PartitionKey": "$context.requestId"
}
```

해당 정보에 대한 자세한 내용은 [링크 글](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecord.html)을 참고하시기 바랍니다.

**3.3.3. PUT - 테스트**

![image](https://user-images.githubusercontent.com/79149004/116773337-d83f3b80-aa8f-11eb-9074-83f8c0429b83.png)

요청 본문에 아래와 같이 입력했는데, 오른쪽 로그를 살펴보면 통합 요청에서 추가했던 매핑 템플릿이 포함되어 전달된 것을 볼 수 있고, 응답 기대 결과로 ShardId가 내려온 것으로 보아 성공적으로 POS 요청이 동작하였음을 알 수 있습니다.

**요청 본문**

```json
{
  "Data": "Test"
}
```

**실제 요청 본문 로그**

```json
{
  "StreamName": "api-gateway-kinesis-test",
  "Data": "ewogICAgIkRhdGEiOiAiVGVzdCIKfQ==",
  "PartitionKey": "e000e702-1ed8-433b-8c8f-8e294684460c"
}
```

## 2.4. Kinesis data streams 데이터 확인

kinesis의 데이터를 가져오기 위해서 [GetRecords 문서](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_GetRecords.html) 를 보면 **POST 요청에 다음과 같은 요청을 body에 포함**해야 합니다.

ShardIterator가 required field 이며 원하는 kinesis stream의 ShardIterator를 알아야 해당 스트림에서 데이터를 꺼내올 수 있다는 의미입니다.

```json
{
  "Limit": number,
  "ShardIterator": "string"
}
```

이를 위해 가이드 문서에서는 api gateway에 `/streams/{stream-name}/sharditerator` 이 리소스의 구현을 통해 연동하는 것을 가이드 하고 있습니다.

본 글에서는 해당 내용을 연동하지 않고, aws cli를 통해 간단히 stream의 데이터를 확인할 수 있는 방법을 진행하고자 합니다.

### 2.4.1. ShardIterator 요청

**요청**

```json
aws kinesis get-shard-iterator \
--stream-name api-gateway-kinesis-test \
--shard-id shardId-000000000000 \
--shard-iterator-type AT_TIMESTAMP \
--timestamp 1609489201
```

stream-name : kinesis stream 이름

shard-id : PutRecord 결과로 받은 응답 shardId

teimstamp : unix epoch time으로 해당 시간 이후로 요청된 내용을 가져오기 위함

**응답**

```json
{
  "ShardIterator": "AAAAAAAAAAETNsov/ad8I319/hcr67iF+GXRfWPGKddiRLLryOUdajcITPhRItI09YJd9ENy4PLyjP0WRxr0ljrFDdRqO6b3FY1tDtt86VMjQEEDSma+LAqSBgz7buORcglJRn8MgDXLLnWJsTlG0uDauZnDi4tfCCnrLDr3FrYO1vOA4j+eAi4fiPDYzuWNH/3BtbocoFn3PrrG/2Nwf3S+oSeu6wpbGrGyrpqWHtD42l2MRGDCyH3d6vq5eQCk2forH0oEh0Rk2B/Uw5P3cIJ4K1UDzEYO"
}
```

### 2.4.2. GetRecords

**요청**

```json
aws kinesis get-records \
--shard-iterator AAAAAAAAAAETNsov/ad8I319/hcr67iF+GXRfWPGKddiRLLryOUdajcITPhRItI09YJd9ENy4PLyjP0WRxr0ljrFDdRqO6b3FY1tDtt86VMjQEEDSma+LAqSBgz7buORcglJRn8MgDXLLnWJsTlG0uDauZnDi4tfCCnrLDr3FrYO1vOA4j+eAi4fiPDYzuWNH/3BtbocoFn3PrrG/2Nwf3S+oSeu6wpbGrGyrpqWHtD42l2MRGDCyH3d6vq5eQCk2forH0oEh0Rk2B/Uw5P3cIJ4K1UDzEYO
```

**응답**

```json
{
  "Records": [
    {
      "SequenceNumber": "49617687179155666429430101670197006370059396208769630210",
      "ApproximateArrivalTimestamp": 1619426371.64,
      "Data": "e30=",
      "PartitionKey": "04294d1f-491d-4ea9-8e28-8923e48d9d2b"
    },
    {
      "SequenceNumber": "49617687179155666429430101670198215295879010975383289858",
      "ApproximateArrivalTimestamp": 1619426373.735,
      "Data": "e30=",
      "PartitionKey": "8130f87d-fc2b-410f-8a22-9a288b8fc11d"
    },
    {
      "SequenceNumber": "49617687179155666429430101670199424221698625673277472770",
      "ApproximateArrivalTimestamp": 1619426374.598,
      "Data": "e30=",
      "PartitionKey": "70d2ec6e-e74f-43f3-94ea-b5b97b779277"
    },
    {
      "SequenceNumber": "49617687179155666429430101670200633147518240302452178946",
      "ApproximateArrivalTimestamp": 1619426374.803,
      "Data": "e30=",
      "PartitionKey": "888809c6-98a7-4c2a-9170-c4988bd13339"
    },
    {
      "SequenceNumber": "49617687179155666429430101670201842073337854931626885122",
      "ApproximateArrivalTimestamp": 1619426374.97,
      "Data": "e30=",
      "PartitionKey": "22601971-e0a1-4749-8b34-18178ae33427"
    }
  ],
  "NextShardIterator": "AAAAAAAAAAH7+NNTZsDi9Sh5qwpc1/mO0f86w56xSq8vkSjHWSxgBzSqZdiTtg89qFTaHfA89m2dwGmGutxeO+2kA7naO0XDlHYE80UywWV6TPmlQBJ54jo6D5ke1hKeZoYQq78jWdf6BdXS8CF4UM3BgmoNyxwKIMZg/aMxNO5H5a9gpaFEZHnIlDwz3ygbdTXFyCjhXcAL+mlmyoF8VmUMZp/Tk85jymj/htqwzrxOYlk2zc27bN5EE48CL0TP45FfUg0nX9Q=",
  "MillisBehindLatest": 0
}
```

위 결과는 해당 스트림에 저장된 데이터의 정보를 출력한 것을 나타냅니다.

## 2.5. S3 버킷 생성

**Amazon S3 → 버킷 만들기**
![image](https://user-images.githubusercontent.com/79149004/116773338-decdb300-aa8f-11eb-8918-c6197e389dd2.png)

화면과 같이 원하는 이름의 bucket을 생성합니다. 다른 bucket 설정은 변경하지 않아도 됩니다.

## 2.6. Kinesis data filehose 생성

**Amazon kinesis → Data Firehose → Create delivery stream**

### 2.6.1. Source stream 지정

![image](https://user-images.githubusercontent.com/79149004/116773344-e4c39400-aa8f-11eb-88d2-a816d91256b8.png)

Kinesis Data Stream을 선택하고, 기존에 생성한 stream을 지정하면 lambda 없이 firehose에서 S3로 stream data를 옮길 수 있습니다.

### 2.6.2. Process records 옵션

![image](https://user-images.githubusercontent.com/79149004/116773350-ee4cfc00-aa8f-11eb-894c-8f1c723eaffd.png)

lambda function을 통해 transform이나 convert 동작을 수행할 수 있는 옵션을 제공하는데, 지금은 사용하지 않고 넘기기로 합니다.

### 2.6.3. Destination 지정

![image](https://user-images.githubusercontent.com/79149004/116773356-f60ca080-aa8f-11eb-857f-451681f8c084.png)

s3로 저장하는 것이 목표이므로 이전 단계에서 만들었던 S3 bucket을 지정하여 설정합니다.

### 2.6.4. configure 설정

![image](https://user-images.githubusercontent.com/79149004/116773365-fc028180-aa8f-11eb-9570-c0192318e6d0.png)

buffer size와 buffer interval 둘 중 하나의 옵션으로 s3로 저장하는 동작이 trigger 됩니다.

위 내용대로라면 5MB 혹은 300sec 넘어갈 경우 s3로 stream 데이터가 이동하게 됩니다.

## 2.7. S3 저장 결과 확인

![image](https://user-images.githubusercontent.com/79149004/116773372-002e9f00-aa90-11eb-9a76-1e80ce3e022b.png)

위 화면과 같이 최종 결과로 stream data가 s3에 저장된 것을 볼 수 있습니다. 1MB, 60sec 값으로 kinesis firehose의 설정을 반영한 결과 입니다.

## 3. 정리

처음엔 AWS 공식 가이드 문서를 쫒아서 진행하는데 의도한대로 잘 동작하지 않았습니다.

같은 문제를 겪는 분들이 있을 것 같아 리서치를 했고 부분마다 안되는 곳들을 찾아서 순서대로 진행해 보았습니다.

처음엔 시간이 지나면 이 글대로도 동작하지 않을 것 같아서 console, cli, serverless 혹은 cdk로 구성하는 방법을 모두 기록으로 남길까 고민했습니다.

하지만 이후 시스템 기능의 변화가 있더라도 큰 흐름은 바뀌지 않을 것 같고 console로 구성하면서 그 과정을 이해한다면 cli나 cdk 등의 구성에서도 큰 어려움을 느끼지 않을 것이라고 생각하여 이쯤에서 마무리 지으려고 합니다.

# 참고자료

[https://docs.aws.amazon.com/ko_kr/apigateway/latest/developerguide/integrating-api-with-aws-services-kinesis.html](https://docs.aws.amazon.com/ko_kr/apigateway/latest/developerguide/integrating-api-with-aws-services-kinesis.html)

[https://haandol.github.io/2020/07/28/apigateway-kinesis-logging.html](https://haandol.github.io/2020/07/28/apigateway-kinesis-logging.html)

[https://chang12.github.io/api-gateway-kinesis-proxy/](https://chang12.github.io/api-gateway-kinesis-proxy/)

[https://joobly.tistory.com/22](https://joobly.tistory.com/22)
