---
title: Go 동시성 패턴 - Pipelines and cancellation (fan in/fan out)
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Golang
tag:
  - 동시성 패턴
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: golang
article_tag2: 동시성패턴
article_tag3: fan in/fan out
article_section: section
meta_keywords: Golang, 동시성 패턴, fan in, fan out
last_modified_at: "2021-04-15 21:03:00 +0800"
---

Golang 동시성 패턴 중 channel을 활용한 fan in/ fan out에 대한 내용을 설명합니다.

# Go 동시성 특성

I / O 및 다중 CPU를 효율적으로 사용하는 스트리밍 데이터 파이프 라인을 쉽게 구성 할 수 있습니다.

# 파이프라인

golang에서 공식적인 개념의 파이프라인은 정해진 것이 없고, 일반적으로 채널로 연결된 일련의 단계를 파이프라인 이라고 일컫습니다.

또한 각 단계는 **동일한 기능을 수행**하는 고루틴 그룹입니다.

- *인바운드* 채널을 통해 *업스트림*에서 값 수신 (소스 또는 생산자) - 1단계
- 해당 데이터에 대해 일부 기능을 수행하여 일반적으로 새로운 값을 생성합니다. - 2단계
- *아웃 바운드* 채널을 통해 값을 *다운 스트림으로* 전송 (싱크 또는 소비자) - 3단계

위 내용을 이해한 바를 그림으로 표현하면 아래와 같습니다.

upstream 과 downstream을 이해하기 쉽게 step을 이어서 그리지 않고 나누어 표현했습니다.

![image](https://user-images.githubusercontent.com/79149004/115551535-33ca3600-a2e6-11eb-8f56-3a7b68816a9f.png)

실제 사례에 활용하는 방법을 위해, kakao, naver, google로 특정 검색을 요청하고 결과를 취합하는 예제를 구성하며 살펴보도록 하겠습니다.

# step 1 : producer

producer는 입력 데이터에 대한 channel 들을 생성합니다.

생성한 채널을 이용해 이후 fan out 단계에서 함수들이 해당 채널로부터 값을 가져갑니다.

이 예제에서는 카카오, 구글, 다음 웹사이트의 주소를 파라미터로 받아 각각에 대한 채널을 생성합니다.

```go
func produceChan(done <-chan struct{}, urls []string) <-chan string {

	// 값을 보낼 목적의 channel을 생성한다.
	outChan := make(chan string, 3)

	// 생성한 channel로 요청이 필요한 url 들을 보낸다.
	go func() {
		// <-done에 의해 갑자기 종료되는 경우에 chan을 close 한다.
		defer close(outChan)
		for _, url := range urls {
			select {
			case outChan <- url:
			case <-done:
				return
			}
		}
	}()

	return outChan
}
```

# step2-1 : fan out

fan out은 채널이 닫히기 전까지 채널 안에 있는 값들을 여러 함수들이 꺼내올 수 있는 것을 말합니다.

하나의 채널 안에 있는 값들을 꺼내서 여러 함수에서 동시적 처리가 가능합니다.

이 예제에서는 카카오, 구글, 다음 웹사이트로 동시에 http get 요청을 합니다.

```go
func fanOut(done <-chan struct{}, outChan <-chan string) <-chan string {

	// 값을 받을 목적의 channel을 생성한다.
	inChan := make(chan string, 3)

	// 동시에 수행해야 하는 operation을 처리한다. 여기서는 http request get 요청을 수행한다.
	go func() {
		// <-done에 의해 갑자기 종료되는 경우에 chan을 close 한다.
		defer close(inChan)
		for url := range outChan {

			resp, err := http.Get(url)
			if err != nil {
				fmt.Println(err)
			}
			defer resp.Body.Close()

			data, err := ioutil.ReadAll(resp.Body)
			if err != nil {
				fmt.Println(err)
			}

			select {
			case inChan <- string(data):
			case <-done:
				return
			}
		}
	}()

	return inChan
}
```

# step2-2 : fan in

fan in은 단일 채널에 fan out때 요청했던 결과들을 입력으로 받아 하나로 모을 수 있습니다.

여기서 fan out의 결과인 입력 채널들이 모두 닫힐때까지 (작업이 완료 될 때 까지) 기다려주는데, sync.WaitGroup을 이용해서 모든 입력 채널들의 작업이 완료되는 것을 기다립니다.

그 결과로 fan in의 outbound chan은 카카오, 구글, 다음의 response body 결과를 들고있게 됩니다.

```go
func fanIn(done <-chan struct{}, outChan ...<-chan string) <-chan string {

	// 동기화를 위해 waitgroup를 사용한다.
	var wg sync.WaitGroup

	// 결과를 합칠 채널을 생성한다.
	merged := make(chan string, 3)

	wg.Add(len(outChan))

	outChanMerge := func(oc <-chan string) {
		// <-done에 의해 갑자기 종료되는 경우에 wait group을 종료한다.
		defer wg.Done()

		// outChan으로부터의 결과를 merge 하는 채널로 전달한다.
		for n := range oc {
			select {
			case merged <- n:
			case <-done:
				return
			}
		}
	}

	for _, ch := range outChan {
		go outChanMerge(ch)
	}

	// 모든 요청에 대한 응답을 동기화하여 합치기 위해 기다린다.
	go func() {
		defer close(merged)
		wg.Wait()
	}()

	return merged
}
```

# step 3 : consume

consume 단계는 fan out/ fan in 과정을 통해 취합된 결과들이 outbound channel에 담겨있는데, 이를 꺼내 활용하는 과정입니다.

```go
func consumeChan(outChan <-chan string) []string {

	result := make([]string, 0, 0)

	for body := range outChan {
		result = append(result, body)
	}
	return result
}
```

# step 4: main 호출

실제로 앞의 과정들을 호출하는 코드는 아래와 같습니다.

done 의 언급에 대해서 본글에 설명이 안되어있는데, 간략히 말씀드리자면, chan 을 통해 데이터를 주고받는 경우 많은 주의를 기울여야 합니다.

의도하지 않게 inbound channel에서 데이터를 무한정 기다리게 될 수도 있고, 닫힌 channel에 값을 넣어버리면 panic이 나는 경우 등이 있기 때문입니다.

이중에 무한정 기다리게되는 hang을 피하기 위해 done 이라는 채널을 두어 명시적 취소 절차를 진행할 수 있습니다.

자세한 내용은 원글 블로그에 자세히 나와있으므로 참고해보시면 좋을 것 같습니다.

```go
func main() {
	done := make(chan struct{})
	defer close(done)

	inChan := produceChan(done, []string{"https://naver.com", "https://google.com", "https://www.daum.net"})
	f1 := fanOut(done, inChan)
	f2 := fanOut(done, inChan)
	f3 := fanOut(done, inChan)

	outChan := fanIn(done, f1, f2, f3)
	result := consumeChan(outChan)

	for _, body := range result {
		fmt.Println(body)
	}
}
```

# 참고자료

https://blog.golang.org/pipelines
