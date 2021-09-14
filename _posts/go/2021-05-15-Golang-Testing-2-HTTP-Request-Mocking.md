---
title: Golang Testing - 2. HTTP Request Mocking
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Golang
tag:
  - Golang, Testing, Unit Test
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: Unit Test
article_tag2: Mock
article_tag3: HTTP request mock testing
article_section: section
meta_keywords: Golang, VS Code Testcode, Unit Test, Mock
last_modified_at: "2021-05-15 17:05:00 +0800"
---

본 글은 golang으로 Testcase를 구성할 때 http request를 실제 서버로 보내지 않고, http request와 관련된 mock을 구현하는 방법에 대해서 설명합니다.

# 0. 시작하기 전에

golang으로 api 서버를 만들다보면 3rd api와 연동해야 하는 일이나 MSA 구조라면 간단한 비즈니스 로직을 처리하기 위해서 다른 서비스로 요청해야 하는 경우가 많을 것 입니다. 이런 상황에서 외부 연동에 대한 코드는 무시하고 fucntional한 unit 테스트만 진행하다 보면 [이전 글](https://0leaf.github.io/golang/Golang-Testing-Unit-Test-%EA%B5%AC%EC%84%B1%ED%95%98%EA%B8%B0/)에서 언급되었던 cover 등으로 확인해봤을때 실제로 많은 영역의 코드를 테스트 할 수 없고 이는 리스크로 남게됩니다.

물론 실제 서버로 직접 요청하는 것을 포함한 unit 테스트를 구성해도 좋지만 만약 다음의 경우라면 문제가 될 가능성이 있습니다.

- 목적지 서버가 k8s 같은 클러스터 내부에 있어 외부에서 직접 호출할 수 없다. (배포 후에나 요청 가능하다)
- 목적지 서버가 먼저 떠있어야 로직상 테스트를 돌릴 수 있기에 배포 순서를 지켜야 한다.
- 단순히 자체 코드에 대한 영향성 만을 보고싶은데 목적지 서버에 종속성이 생긴다.
- 실제 서버로 요청해버리면 응답 속도가 너무 늦어 테스트나 배포 시간이 오래 걸린다.

이러한 불편한 상황을 막기 위해 local에서 기대되는 요청에 대한 응답을 mocking 하여 실제 서버에는 요청하지 않지만 마치 요청에 대한 응답을 받은 것 같은 기대효과를 얻을 수 있습니다.

# 1. 예제 시나리오

예를 들면 아래 그림처럼 productpage 서버를 구현한다고 가정해봅시다. 그러면 details 서버와 review 서버로 요청을 보낸 뒤 사용자에게 응답을 내려주는 기능을 구현해야 합니다.

그리고 details 서버와 reviews 서버는 외부에서 호출이 불가능하도록 구현이 되어있고, 배포 후에 해당 망 안에서 호출할 수 있는 경우라고 가정해봅니다.

이런 경우엔 실제 서버로 요청을 보내는 기능을 포함해서 테스트케이스를 구성할 수 없습니다. 이런 문제 상황을 극복하기 위해 HTTP Request를 mocking 하는 방법에 대해 기술하고자 합니다.

![image](https://user-images.githubusercontent.com/79149004/118353119-eae16680-b59f-11eb-9190-242552bcf7a0.png)
[https://raw.githubusercontent.com/kiali/kiali.io/master/static/images/documentation/features/graph-overview.png](https://raw.githubusercontent.com/kiali/kiali.io/master/static/images/documentation/features/graph-overview.png)

# 2. Interface 에 대한 이해

먼저 본 과정을 이해하시려면 interface를 이해하셔야 합니다. 다른 java나 c++ 같은 객체 지향 언어를 공부하신 분들이라면 잘 알고계실 다형성과 관련된 이야기 입니다. 쉽게 이야기하실 수 있도록 그림을 하나 두고 이야기해보겠습니다. 혹시라도 제대로 interface에 대해 공부하시고 넘어가고 싶으시다면, 관련해서 깊게 다룬 글들을 쉽게 검색해서 찾아보실 수 있으므로 잠깐 이 글 읽는 것을 멈춘뒤 이해하고 나서 진행하시는 것도 좋습니다.

![image](https://user-images.githubusercontent.com/79149004/118353128-f03eb100-b59f-11eb-9d9a-c19b704f7dcb.png)

그림 출처 : [https://docsplayer.org/77693386-Powerpoint-프레젠테이션.html](https://docsplayer.org/77693386-Powerpoint-%ED%94%84%EB%A0%88%EC%A0%A0%ED%85%8C%EC%9D%B4%EC%85%98.html)

사실 이 글에서 다루려고 하는건 복잡한 내용이 아니라 http clinet의 mocking과 관련된 부분만 언급하려고 합니다.

그림으로 보시면 유명하고 뻔한 짖다 모델을 가져왔습니다. **"짖다" 의 동작을 "누가" 하는지에 따라 다르게 처리한다**. 이 정도 개념으로만 이해하시면 충분할 것 같습니다.

> **"짖다 - httpRequset"** 라는 동작을

> **본 코드(강아지)** 가 하면 **"멍멍"**

> **테스트 코드(고양이)** 가 하면 **"야옹"**

과 같은 느낌이 되겠네요.

golang에서도 이러한 구현을 위해 interface 기능을 제공합니다.

# 3. 테스트 구성

## 3.1. 예제 시나리오

이번 예제에서도 자주 쓰는 google, naver, kakao로 http 요청을 하는 정말 간단한 코드를 두고 테스트케이스를 구성해보도록 하고, 구현 먼저 하고 테스트코드를 작성하는 순서로 진행하겠습니다.

또한 golang 기본 tool 로 제공하는 cover 사용 및 testcase 구성 방법 등은 [Golang Testing - Unit Test 구성하기](https://0leaf.github.io/golang/Golang-Testing-Unit-Test-%EA%B5%AC%EC%84%B1%ED%95%98%EA%B8%B0/)를 참고하시면 도움됩니다.

## 3.2. 직접 호출 기반 UnitTest 구성

**main.go**

```go
package main

import (
	"fmt"
	"io"
	"net/http"
)

func requestPortal (metod, url string) (*string, error) {

	req, err := http.NewRequest(metod, url, nil)
	if err != nil {
		return nil, err
	}

	cli := &http.Client{}
	resp, err := cli.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// golang 1.16 부터 io.ReadAll 사용 가능
	b, _ := io.ReadAll(resp.Body)
	result := string(b)

	return &result, nil
}

func main() {
	urlList := []string{"https://google.com", "https://naver.com", "https://daum.net", "https://myportal.my"}
	for _, url := range urlList {
		res, err := requestPortal (http.MethodGet, url)
		if err != nil {
			fmt.Println(err)
		} else {
			fmt.Println(*res)
		}
	}
}
```

**main_test.go**

```go
package main

import (
	"fmt"
	"net/http"
	"strings"
	"testing"
)

func Test_requestPortal (t *testing.T) {

	expectedResult := "google"
	type args struct {
		metod string
		url   string
	}
	tests := []struct {
		name    string
		args    args
		want    *string
		wantErr bool
	}{
		{
			name: " TC1. 포털 사이트 요청 테스트",
			args: args{
				metod: http.MethodGet,
				url:   "https://gogole.coom",
			},
			want:    &expectedResult,
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := requestPortal (tt.args.metod, tt.args.url)
			fmt.Println(err)
			if err == nil {
				if !strings.Contains(*got, *tt.want) {
					t.Errorf("requestPortal () = %v, want %v", got, tt.want)
				}
			}
		})
	}
}
```

**테스트 결과**

```go
$go test -coverprofile=cover.out
coverage: 52.9% of statements
ok      test    0.593s
$go tool cover -html=cover.out
```

![image](https://user-images.githubusercontent.com/79149004/118353144-fa60af80-b59f-11eb-981a-dd68a8de9870.png)

3.3 과정에서는 직접 목적지 서버에 요청을 하는 과정을 unit 테스트로 구성하였고, 그 결과 main 함수 외에 대부분의 statement가 커버됨을 확인할 수 있습니다.

## 3.4. 문제 발생 케이스

만약 google.com이 아니라... 예제에서 들었던 것 처럼 현재 테스트 수행 환경에서는 호출 불가능한 목적지 서버로 호출해야 하는 경우가 있다면 어떨까요.

그러니까 internal 환경으로 배포하고 나면 코드상에 구현되어 있는 url로 정상 동작하지만 배포 전 내 컴퓨터에서 닿지 않는 곳의 목적지 서버로 요청을 보내야 하는 경우에는 테스트를 어떻게 해야할까요.

확인을 위해 gogole.coom 이라는 존재하지 않는 페이지로 요청을 보내는 테스트케이스를 구성해 보겠습니다.

**테스트 결과**

```go
$go test -coverprofile=cover.out
Get "https://gogole.coom": dial tcp: lookup gogole.coom: no such host
PASS
coverage: 35.3% of statements
ok      test    0.014s
$go tool cover -html=cover.out
```

![image](https://user-images.githubusercontent.com/79149004/118353150-02b8ea80-b5a0-11eb-83fc-111396b89e27.png)

coverage 수치로도 확실히 줄었고, cover 툴을 이용해서 확인해봐도 존재하지 않는 host로의 요청에 의해 응답이후를 처리하는 부분들이 커버되지 않았습니다.

뿐만 아니라 이 테스트코드를 가진 상태로 Makefile 등을 구성하면 testcase가 Fail이 나기 때문에 배포 환경에 따라 문제가 발생할 수 있습니다.

## 3.5. Mock Client 구성

이제 Mock client를 구성할 차레입니다. 앞 단계에서 쉬운 예로 들었던 내용처럼

> **"짖다(Do)"** 의 기능을

> **"main.go"**에서 하면 **"http.client{} 로 구현된 Do 수행"** - 강아지

> **"main_test.go"**에서 하면 "**MockClient{} 로 새롭게 구현된 Do 수행"** - 고양이

하도록 구성할 것 입니다.

이를 위해 Do를 담을 HTTPClient 라는 이름의 interface를 선언하고, 실제 동작할 함수의 구현은 리시버에 그 handler 타입을 받아 구현합니다.

**main.go**

```go
package main

import (
	"fmt"
	"io"
	"net/http"
)

// HTTPClient interface
type HTTPClient interface {
	Do(req *http.Request) (*http.Response, error)
}

type Handler struct {
	cli HTTPClient
}


func NewRequestHandler() *Handler {
	return &Handler{
		cli: &http.Client{},
	}
}

func (h Handler) requestPortal (metod, url string) (*string, error) {

	req, err := http.NewRequest(metod, url, nil)
	if err != nil {
		return nil, err
	}

	// 이 부분을 interface로 정의된 HTTPClient type, &http.clinet{} 값을 갖는 값으로 지정한다.
	// 이렇게 되면 Do(req *http.Request) (*http.Response, error) 의 기능은 원래 존재하는 http client의 Do 함수를 사용한다.
	// 실제 코드를 이렇게 구성하면 의도한대로 동작한다.
	cli := h.cli
	resp, err := cli.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// golang 1.16 부터 io.ReadAll 사용 가능
	b, _ := io.ReadAll(resp.Body)
	result := string(b)

	return &result, nil
}

func main() {
	urlList := []string{"https://google.com", "https://naver.com", "https://daum.net", "https://myportal.my"}
	for _, url := range urlList {

		//이 부분도 handler를 통해 호출하는 방식으로 변경해준다.
		res, err := NewRequestHandler().requestPortal (http.MethodGet, url)
		if err != nil {
			fmt.Println(err)
		} else {
			fmt.Println(*res)
		}
	}
}
```

**main_test.go**

```go
package main

import (
	"bytes"
	"io"
	"net/http"
	"testing"
)

// MockClient is the mock client
type MockClient struct {
}

// Do 를 재구현 함으로써 MockClient 어댑터로 구현된 기능은 본래의 Do와 다르게 동작한다.
func (m *MockClient) Do(req *http.Request) (*http.Response, error) {
	json := `{ "description": "okay" }`
	r := io.NopCloser(bytes.NewReader([]byte(json)))
	defer r.Close()

	return &http.Response{
		Status:     "200 Ok",
		StatusCode: http.StatusOK,
		Body:       r,
	}, nil
}

func TestHandler_requestPortal (t *testing.T) {

	h := NewRequestHandler()
	// MockClient로 cli를 변경해주면서 MockClient 어댑터로 새로 구현된 Do가 호출된다.
	h.cli = &MockClient{}

	expectedResult := `{ "description": "okay" }`
	type fields struct {
		cli HTTPClient
	}
	type args struct {
		metod string
		url   string
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		want    *string
		wantErr bool
	}{
		{
			name: " TC1. 포털 사이트 요청 테스트",
			args: args{
				metod: http.MethodGet,
				url:   "https://gogole.coom",
			},
			want:    &expectedResult,
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := h.requestPortal (tt.args.metod, tt.args.url)
			if (err != nil) != tt.wantErr {
				t.Errorf("requestPortal () error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if *got != *tt.want {
				t.Errorf("requestPortal () = %v, want %v", got, tt.want)
			}
		})
	}
}
```

**테스트 결과**

```go
$go test -coverprofile=cover.out
PASS
coverage: 55.6% of statements
ok      test    0.009s
$go tool cover -html=cover.out
```

![image](https://user-images.githubusercontent.com/79149004/118353157-0b112580-b5a0-11eb-8fa9-51a7efa4d828.png)

호출할 수 없는 url로 구성한 unit 테스트 구성으로도 코드의 syntax 나 panic을 확인해 볼 수 있는 converage 를 확보할 수 있는 것을 알 수 있습니다.

# 4. 정리

테스트의 중요성은 실제로 문제를 겪어보면 절실히 깨닫게 되는 것 같습니다. 소잃고 외양간 고치는 느낌처럼 문제가 발생한 뒤에 해결하려고 한다면 이미 입은 피해는 되돌릴 수 없다는 것도 잘 알게됩니다.

테스트 구성은 안했지만 자주 호출되는 부분들은 몇번 테스트 해봤는데 잘 동작하니까 그대로 배포해버리고 잊어버리고 살고 있다면, 갑자기 발생한 critical 한 이슈를 개선하려고 기억도 잘 나지 않는 코드에서 헤메게 될 가능성이 있습니다.

갑자기 발생한 코너케이스나 엣지케이스로 panic이 발생하고, 이를 복구할 수 있는 최소한의 recover나 error handling이 안되어 있다면 복구하는데 드는 리소스 뿐만 아니라 비즈니스에도 큰 영향을 주게 됩니다.

따라서 Test driven 설계를 하거나, 설계 이후에 Test code를 구성하거나 하는 작업은 무시되어선 안된다고 생각합니다. 사실 Testcase를 구성하는 과정에서 coverage를 함께 보다 보면 놓쳤던 부분들이 하나씩 볼 수 있는 경험을 하게되는 것 같습니다.

# 참고자료

[https://www.thegreatcodeadventure.com/mocking-http-requests-in-golang/](https://www.thegreatcodeadventure.com/mocking-http-requests-in-golang/)

[https://quii.gitbook.io/learn-go-with-tests/go-fundamentals/mocking](https://quii.gitbook.io/learn-go-with-tests/go-fundamentals/mocking)

[https://levelup.gitconnected.com/mocking-outbound-http-calls-in-golang-9e5a044c2555](https://levelup.gitconnected.com/mocking-outbound-http-calls-in-golang-9e5a044c2555)
