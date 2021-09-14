---
title: Postman을 활용한 자동 REST API 테스트
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Testing
tag:
  - Testing, Postman, REST
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: Testing
article_tag2: Postman
article_tag3: API Test
article_section: section
meta_keywords: Testing, Postman, API Test, Newman
last_modified_at: "2020-05-05 14:35:00 +0800"
---

postman과 newman cli를 활용하여 REST API를 테스트 하는 방법을 설명합니다.

# 0. 들어가기 전에

이번에는 REST API를 테스트하는 방법으로 Postma 툴을 활용하는 방법에 대해서 기술해보도록 하겠습니다. Postman 평소에 자주 사용하던 툴이기도 했는데, API를 시나리오 기반으로 자동으로 테스트하는 셋을 구성하고 싶은 생각에 몇몇 방법을 찾아봤으나, 해당 방법이 제일 간단한 것 같아서 정리합니다.

Postman에 대한 자세한 내용은 [여기](https://www.postman.com/)서 확인하실 수 있고 운영체제에 맞는 툴을 다운로드 받거나 웹 기반으로도 서비스를 제공하고 있습니다.

Postman 툴은 글 작성 시점 기준으로 무료이며, 원하는 추가 기능을 사용하려면 비용을 지불해야 합니다. 자세한 내용은 공식 홈페이지에서 참고하시기 바랍니다. 본 글은 무료 계정을 사용하였습니다.

# 1. Workspace 생성

![image](https://user-images.githubusercontent.com/79149004/117138404-f4bbda80-ade5-11eb-8b59-b6e44fa1986b.png)

위 화면 내용처럼 Workspace를 생성합니다. Visibility는 Personal, Team, Private, Public 에서 선택을 합니다.

# 2. API 요청 구성

요청할 API를 찾으신다면 [네이버 개발자 센터](https://developers.naver.com/docs/common/openapiguide/apilist.md#%EB%B9%84%EB%A1%9C%EA%B7%B8%EC%9D%B8-%EB%B0%A9%EC%8B%9D-%EC%98%A4%ED%94%88-api) 같은 곳에 친절하게 설명되어 있는 api들이 많습니다. 다만 저는 조금 간단히 하기 위해 웹 검색의 url을 그냥 가져와보도록 하겠습니다.

위 링크에 접속해보면 API 요청에 대한 정보를 얻을 수 있고 이 내용을 Postman에서 구성해보도록 하겠습니다.

![image](https://user-images.githubusercontent.com/79149004/117138423-fa192500-ade5-11eb-942b-578acd16c629.png)

강남역 맛집을 네이버에서 검색하면 위와 같이 GET 요청에 대한 URL이 생성됩니다. 이것을 Postman으로 요청해보겠습니다.

![image](https://user-images.githubusercontent.com/79149004/117138446-ff766f80-ade5-11eb-8c14-5231bca79976.png)

위와 같이 사용하는 법은 너무 간단합니다. URL을 붙여넣으니 쿼리 파라미터에도 자동으로 들어가는군요. 응답으로는 사용자들에게 보여줄 HTML 페이지 전문이 내려옵니다.

# 3. 테스트 셋 구성

그러면 이제 원래 하고싶었던 내용에 대해서 기술해보도록 하겠습니다. 서버를 배포할때 API에 대해서 테스트를 자동으로 해보고 싶을 경우 Postman에서 일부분 관련 기능을 제공해줍니다. 그 기능들에 대해 적어봅니다.

## 3.1 변수의 활용

먼저 테스트에도 활용될 수 있지만 변수에 대해서 이야기 해보려고 합니다. postman에서 변수 기능을 제공하고 있습니다.

![image](https://user-images.githubusercontent.com/79149004/117138462-056c5080-ade6-11eb-8b97-f27826955254.png)

위 화면처럼 우측 상단에 눈 모양의 버튼을 누르면 변수를 설정할 수 있는데, 이 기능은 나중에 자동화 테스트를 위해 collection을 export 해야하는데, **Environment와 Globals 변수는 export에 포함되지 않습니다. 따라서 아래 화면의 박스쳐진 부분을 선택해서 반드시 Collection 변수로 설정**해줍니다.

![image](https://user-images.githubusercontent.com/79149004/117138480-0a310480-ade6-11eb-9d30-05f1bc60ab8a.png)

이런식으로 저장하면 아래와 같이 **{{ 변수명 }}** 을 통해 여러 곳에서 재사용 할 수 있습니다. 이 변수는 테스트케이스 구성에서도 사용될 예정입니다. 다만 Environment 변수나 Global 변수가 아닌 **Collection 변수로 지정했는지 다시 한번 확인**해주시기 바랍니다.

![image](https://user-images.githubusercontent.com/79149004/117138498-0f8e4f00-ade6-11eb-9d74-3e1c4509b007.png)

잘 설정된 예 - C : Colllection 변수로 지정되어야 export에 포함됩니다.

![image](https://user-images.githubusercontent.com/79149004/117138510-14530300-ade6-11eb-92d3-0f896af4a165.png)

잘못 설정된 예 - E : Environment나 Gloval 변수로 지정해서 사용하면 해당 작업환경에선 동작하지만 collection을 json으로 export 할때 포함되지 않아 문제가 발생합니다.

## 3.2 테스트 작성

![image](https://user-images.githubusercontent.com/79149004/117138521-1917b700-ade6-11eb-896f-42f1047bee3f.png)

오늘 주로 이야기하고 싶은 기능들은 모두 붉은색 네모 부분들입니다.

테스트 절차을 수행하기 위한 코드는 javascript로 구성됩니다. Tests를 누르면 나오는 화면에서 오른쪽 네모 박스 부분은 자주 쓰이는 테스트 구성에 대한 예제 인데 클릭하면 자동으로 관련된 javascript가 왼쪽 입력 칸에 들어오게 됩니다.

Tests 기능을 통해 http response code, body 등의 정보를 바탕으로 해당 요청이 성공적이었는지를 테스트 할 수 있습니다.

Pre-request Script 기능을 이용해 테스트의 Precondition을 수행할 수 있습니다. 변수를 지정한다던지 어떤 요청을 수행하기 전에 미리 설정을 진행할 수 있습니다.

### 3.2.1. Pre-request Script 구성

오른쪽 SNIPPET 구성에서 **get an environment variable**, **set an environment variable** 두 개를 이용해서 간단히 테스트해봅니다.

```jsx
const TestInput1 = pm.environment.get("TestInput1");
pm.environment.set("TestInput1", TestInput1 + "네이버 맛집 검색결과");
```

위와 같은 코드를 구성하고 request를 반복해서 요청하면 실제 변수에 해당 값이 저장됨을 볼 수 있습니다.

![image](https://user-images.githubusercontent.com/79149004/117138546-203ec500-ade6-11eb-8759-6e422a7924f2.png)

### 3.2.2. Tests 구성

테스트 해볼 내용은 다음과 같습니다. 물론 기능의 동작을 확인하기 위한 내용이라 실제 테스트 설계 방법과 연관해서 생각하시지 않으셨으면 좋겠습니다.

- TestInput1 변수의 내용에 **네이버 맛집 검색결과** 가 존재하는가
- response code가 200으로 내려오는가
- response body내 맛집 내용이 포함되어 있는가

```jsx
const TestInput1 = pm.environment.get("TestInput1");

pm.test("TestInput1 contains 네이버 맛집 검색결과", function () {
  pm.expect(TestInput1).to.include("네이버 맛집 검색결과");
});

pm.test("Status code is 200", function () {
  pm.response.to.have.status(200);
});
pm.test("Body matches string", function () {
  pm.expect(pm.response.text()).to.include("맛집");
});
```

![image](https://user-images.githubusercontent.com/79149004/117138556-25037900-ade6-11eb-8b61-0e1df58f52c8.png)

위 화면 결과처럼 각 테스트에 대한 결과를 확인할 수 있습니다.

## 3.3. 여러 테스트 동시 수행

왼쪽 화면 → 실행 Collection 마우스 우클릭 → Run collection

![image](https://user-images.githubusercontent.com/79149004/117138572-2af95a00-ade6-11eb-95d2-605e1b9c9968.png)

여러 테스트 진행을 확인하기 위해 지금까지 한 과정을 복사했습니다. 총 6개를 Run collection 하면 테스트 수행을 순차적으로 하고 이때 순서와 횟수 등을 변경할 수 있습니다. 그 결과로 레포트까지 얻을 수 있습니다.

# 4. 자동화 API 테스트와 CI/CD 연동

postman에서 collection을 cli로 실행할 수 있는 newman([npm](https://www.npmjs.com/package/newman)/[docker](https://hub.docker.com/r/postman/newman/)) 이라는 도구를 제공합니다. 이 도구를 활용한다면 기 작성한 postman collection을 활용하여 배포 과정에 API 테스트를 포함시킬 수 있습니다.

# 5. 정리

API 설계와 명세 그리고 테스트까지... postman 뿐만 아니라 swagger나 다른 툴 및 방법들을 사용해보았는데 각 도구가 저에게 딱 맞지 않고 조금씩 부족한 부분들이 있었던 것 같습니다. 그래서 저는 필요한 경우에 맞게 선택해서 사용하거나 섞어서 활용하고 있습니다.

하지만 이 글의 목적은 API 테스트 설계 도구로 Postman을 사용해보면 어떨까 에서 출발했고 그 간단한 사용법을 남기는 것이었습니다. SW 테스트와 관련해서 공부하다보면 늘 앞부분에 나오는 말중에 하나는 "**완벽한 테스트는 없다"** 인 것 같습니다. 그만큼 테스트를 많이 해도 완벽할 수 없다는 말인데, 그를 위해서 최소한 테스트를 쉽게 설계할 수 있는 도구나 방법이 중요하다고 생각합니다. 그런 이유로 Postman은 이런 요구를 충족할 수 있는 대안이 될 수 있을 것 같습니다.

# 참고자료

[https://www.youtube.com/watch?v=z0MimkXIvE8](https://www.youtube.com/watch?v=z0MimkXIvE8)

[https://blog.postman.com/newman-run-and-test-your-collections-from-the-command-line/](https://blog.postman.com/newman-run-and-test-your-collections-from-the-command-line/)

[https://dev.to/leading-edje/hello-newman-how-to-build-a-ci-cd-pipeline-that-executes-api-tests-2h5l](https://dev.to/leading-edje/hello-newman-how-to-build-a-ci-cd-pipeline-that-executes-api-tests-2h5l)

[https://community.postman.com/t/how-do-i-set-a-collection-variable/5466](https://community.postman.com/t/how-do-i-set-a-collection-variable/5466)
