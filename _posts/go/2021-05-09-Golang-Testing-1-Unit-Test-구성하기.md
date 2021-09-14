---
title: Golang Testing - 1. Unit Test 구성하기
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
article_tag2: Coverage
article_tag3: Benchmark
article_section: section
meta_keywords: Golang, VS Code Testcode, Unit Test, Coverage, Benchmark
last_modified_at: "2021-05-09 21:03:00 +0800"
---

본 글은 Golang으로 개발함에 있어 Testing 패키지를 활용해 Test를 구성/수행 및 Coverage와 Benchmark를 확인할 수 있는 방법에 대해 설명합니다.

# 0. 시작하기 전에

golang으로 개발을 진행하면서 많은 api 서버를 구성했습니다. 개발 기간의 부족, 테스트에 대한 범위의 모호 등 합리적이지 않은 합리화로 unit 테스트 코드를 작성하는데 소흘했던 것 같습니다.

혹시나 누군가는 테스트 코드를 작성하고는 싶은데, 어떻게? 어디까지? 등에 대해서 궁금증을 갖고 계신분이 있을 수 있어 테스트와 관련해서 조금씩 덧붙여 작성해보려고 합니다.

이번 글에서는 TDD 같은 개발 방법론에 대한 이야기를 하지 않고 단순하게 테스트 코드를 만드는 과정에 대해서만 언급하려고 합니다.

## 0.1. 개발 환경 (갑자기..?)

저는 평소 개발할때 다양한 언어를 사용하거나 인프라 코드들을 편집합니다. python, golang, java, javascript, html, shell, json, yaml... 한동안 JetBrains 사의 Professional 도구들을 사용하곤 했는데, 언어마다 다른 도구로 존재해서 그 마다 전문성이 느껴지고 좋은 기능들이 너무 많지만 단축키나 환경 설정들이 각 툴마다 조금씩 다른 것에 대한 아쉬움을 느꼈습니다.

![Untitled](https://user-images.githubusercontent.com/79149004/117565350-a65f5200-b0eb-11eb-8540-ca3ea37e59e5.png){:.aligncenter width="330" height="350"}

그래서 저는 각 도구의 전문성을 포기하고 VS Code로 통합해서 개발해보는 방법으로 Golang 개발을 VS Code로 하고 있습니다. 편리한 플러그인들이 많은데 이 설치한 환경 자체도 github와 연동해 어디서든 동기화 시킬 수 있습니다. (VS Code 얘기는 그만....)

**갑자기 뜬금없이 왜 개발환경을 이야기하냐 물어보신다면** 테스트 코드를 구성하는 것은 결국 생산성에서 문제를 겪게 된다고 생각합니다. 매번 테스트 코드를 컨벤션에 따라 직접 구성하는것도 좋지만,

만약 **도구에서 효율적으로 자동으로 만들어주는 부분이 있다**면 적극 활용하는게 좋을 것 같다고 생각했습니다.

**VS Code에 그 기능이 존재**해서 소개드리고자 합니다. (JetBrains 사의 GoLand도 같은 기능을 갖고 있습니다.)

# 1. 테스트 코드 만들기

## 1.1. 직접 만들기

golang.org의 [testing](https://golang.org/pkg/testing/) package 내용은 시간이 허락한다면 꼭 한번 읽어보시기 바랍니다.

본 글에서 자세하게 언급하지 않는 테스트 코드 구성에 대한 Convention 및 방법들에 대해 잘 설명되어 있습니다.

Convention 부분만 간단히 말씀드리면 아래와 같습니다. 이 부분들은 단순히 Convention 뿐만 아니라 Test 수행할때 참고하는 부분이 되므로 꼭 기준에 맞춰서 만들어야 합니다.

```go
1. test file 이름은 _test.go로 끝난다.
2. test file 내 Test Function 이름은 func TestXxx(*testing.T)로 구성한다. (X가 대문자를 의미)
```

간단히 **1~n 까지 합을 구하는 함수**를 만들고 **테스트 코드를 구성**해 보겠습니다.

**sumnumbers.go**

```go
package main

func SumNumbers(n int) int {
	s := 0
	for i := 1; i <= n; i++ {
		s += i
	}
	return s
}
```

**sumnumbers_test.go**

```go
package main

import "testing"

func TestSumNumbers(t *testing.T) {
	got := SumNumbers(10)
	if got != 55 {
		t.Errorf("SumNumbers(10) = %d; want 55", got)
	}
}
```

**테스트 실행 : go test -run '' -v**

```go
=== RUN   TestSumNumbers
--- PASS: TestSumNumbers (0.00s)
PASS
ok      test    0.005s
```

실행 방법에 대해서는 2.1. Test Execution 부분에서 언급하고 있기도 하고 이 단계는 단순한 결과만을 보여드리기 위함이니 그냥 넘어가셔도 좋습니다.

## 1.2. IDE(VS Code) 기능으로 자동 생성하기

![Golang Testing - Unit Test 구성하기 a039d2176bc5450abb504a9745ec93f9](https://user-images.githubusercontent.com/79149004/117565345-9fd0da80-b0eb-11eb-9df0-58d4c21e11c4.gif){:.aligncenter}

글의 앞부분에서 이미 말씀드린 대로 VS Code는 Convention에 맞는 Unit Test 템플릿 코드를 자동으로 생성해주는 기능을 갖고 있습니다.

**테스트 코드를 생성하고 싶은 부분의 함수명에서 마우스를 우클릭**하고

**Go: Generate Unit Tests For Function** 을 선택해주면 자동으로 Convention에 맞는 파일 및 함수가 생성됩니다.

이때 자동으로 생성된 Unit 테스트 구성은 [Table-driven 방식](https://blog.golang.org/subtests)을 기본 골짜로 하여 생성됩니다.

**sumnumbers_test.go**

자동 생성된 결과에 Table driven 형태의 TC를 추가했습니다.

```go
package main

import "testing"

func TestSumNumbers(t *testing.T) {
	type args struct {
		n int
	}
	tests := []struct {
		name string
		args args
		want int
	}{
		// TODO: Add test cases.
		{
			name: "TC1_TestSumNumbers: okcase",
			args: args{
				n: 10,
			},
			want: 55,
		},
		{
			name: "TC2_TestSumNumbers: okcase",
			args: args{
				n: 1,
			},
			want: 1,
		},
		{
			name: "TC3_TestSumNumbers: failcase",
			args: args{
				n: -10,
			},
			want: 55,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := SumNumbers(tt.args.n); got != tt.want {
				t.Errorf("SumNumbers() = %v, want %v", got, tt.want)
			}
		})
	}
}
```

**테스트 실행 : go test -run '' -v**

```go
=== RUN   TestSumNumbers
=== RUN   TestSumNumbers/TC1_TestSumNumbers:_okcase1
=== RUN   TestSumNumbers/TC2_TestSumNumbers:_okcase2
=== RUN   TestSumNumbers/TC3_TestSumNumbers:_failcase1
    main_test.go:40: SumNumbers() = 0, want 55
--- FAIL: TestSumNumbers (0.00s)
    --- PASS: TestSumNumbers/TC1_TestSumNumbers:_okcase1 (0.00s)
    --- PASS: TestSumNumbers/TC2_TestSumNumbers:_okcase2 (0.00s)
    --- FAIL: TestSumNumbers/TC3_TestSumNumbers:_failcase1 (0.00s)
FAIL
exit status 1
FAIL    test    0.005s
```

이런식으로 하나의 함수 안에서 단위테스트를 여러개를 구성할 수 있습니다. TC3_TestSumNumbers:\_failcase1 는 의도적으로 테스트의 실패 케이스를 넣어 두었습니다.

# 2. 테스트 수행 방법 및 기능 살펴보기

## 2.1. Test Execution

테스트를 수행하는 다양한 방법 역시 [testing](https://golang.org/pkg/testing/) package document에 잘 기술되어 있습니다. 이전 단계에서 skip, subtesting 등에 대해서 언급하지 않았으므로 해당 내용이 궁금하신 분은 testing package 링크 글을 참고하시기 바랍니다.

테스트를 수행할땐 다음과 같은 명령으로 수행합니다. -run 뒤의 값으로 테스트를 수행할 조건 대상을 선정할 수 있고 -v를 붙여주면 자세한 결과를 확인할 수 있습니다.

**실행방법**

```go
go test -v -run ''  # Run all tests.
go test -v Foo      # Run top-level tests matching "Foo", such as "TestFooB -var".
go test -v Foo/A=   # For top-level tests matching "Foo", run subtests matching "A=".
go test -v /A=1     # For all top-level tests, run subtests matching "A=1".
```

기본적으로 특정 패키지의 파일들을 test하고 싶을 경우 해당 위치에서 go test -v 만 해도 쉽게 확인할 수 있습니다.

## 2.2. Code Coverage Testing

testing package를 통해 testcase를 구성하고 나면 code coverage또한 체크할 수 있는 이점이 있습니다. [go blog Cover](https://blog.golang.org/cover)와 관련된 글을 참고하여 해당 내용을 정리해보도록 하겠습니다.

커버리지 측정 관련된 내용이므로 쉽게 확인하기 위해 예제 코드를 Cover 글에서도 이야기하고 있는 switch 문을 포함하는 예제로 살펴보겠습니다.

### 2.2.1. Test coverage for Go

**예제 코드**

```go
package main

func Size(a int) string {
	switch {
	case a < 0:
		return "negative"
	case a == 0:
		return "zero"
	case a < 10:
		return "small"
	case a < 100:
		return "big"
	case a < 1000:
		return "huge"
	}
	return "enormous"
}
```

**예제 테스트 코드**

일부러 모든 경우를 충족시키지 않기 위해 negative, small 부분만 확인하도록 구성합니다.

```go
package main

import "testing"

func TestSize(t *testing.T) {
	type args struct {
		a int
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{
			name: "negative check",
			args: args{-1},
			want: "negative",
		},
		{
			name: "small check",
			args: args{5},
			want: "small",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Size(tt.args.a); got != tt.want {
				t.Errorf("Size() = %v, want %v", got, tt.want)
			}
		})
	}
}
```

**실행 방법**

```go
go test -v -cover #(테스트 코드 경로)
```

**실행 결과**

```go
=== RUN   TestSize
=== RUN   TestSize/negative_check
=== RUN   TestSize/small_check
--- PASS: TestSize (0.00s)
    --- PASS: TestSize/negative_check (0.00s)
    --- PASS: TestSize/small_check (0.00s)
PASS
coverage: 33.3% of statements
ok      test    0.005s
```

위 결과는 statement coaverage 측정 기준으로 33.3%를 충족하는 결과를 보여줍니다. 예상했던 대로 테스트 케이스를 충분하게 작성하지 않았기 대문에 모든 case를 돌지 못한 결과입니다.

[coverage](https://ko.wikipedia.org/wiki/%EC%BD%94%EB%93%9C_%EC%BB%A4%EB%B2%84%EB%A6%AC%EC%A7%80)의 경우도 statment coverage 외에 다양한 기준과 방법이 존재하지만 여기서는 statement coverage만 다루도록 하겠습니다.

### 2.2.2. Viewing the results

golang에서 기본으로 제공하는 강력한 툴중에 cover라는 도구를 사용하면 정확히 어떤 영역들의 코드가 cover 되었는지를 아래와 같은 방법으로 확인할 수 있습니다.

- -coverprofile 옵션으로 커버리지 정보를 추출한 파일을 생성합니다.
- -func / -html 둘 중 하나의 옵션으로 상세 coverage 정보를 확인합니다.

**coverprofile 생성**

여기서 statement가 여러번 호출될 경우 진하게 표시하기 위해 -covermode=count를 추가했습니다.

```go
go test -v -covermode=count -coverprofile=coverage.out
```

**cover tool의 -func 옵션을 이용한 coverage 측정 결과**

```go
go tool cover -func=coverage.out

test/main.go:5: main            0.0%
test/size.go:3: Size            42.9%
total:          (statements)    33.3%
```

**cover tool의 -html 옵션을 이용한 coverage 측정 결과**

```go
go tool cover -html=coverage.out
```

![Untitled 1](https://user-images.githubusercontent.com/79149004/117565349-a4958e80-b0eb-11eb-8169-3a898da86e0b.png){:.aligncenter width="430" height="330"}

위 결과를 보면 어느 부분의 코드가 테스트되지 않았고, 어떤 식으로 테스트 케이스를 추가해야되는지 직관적으로 알 수 있습니다.

## 2.3. Benchmark Testing

기존의 테스트 코드에 아래의 Convention에 따라 필요한 내용을 추가하면 Benchmark Testing을 수행할 수 있습니다. Benchmark는 성능을 평가할때 사용하는데 활용될 수 있습니다.

```go
1. test file 이름은 _test.go로 끝난다.
2. test file 내 Benchmark Function 이름은 func BenchmarkXxx(*testing.B)로 구성한다. (X가 대문자를 의미)
```

**sumnumbers_test.go**

```go
func BenchmarkSumNumbers(b *testing.B) {

	for i := 0; i < b.N; i++ {
		SumNumbers(10)
	}
}
```

위 코드를 기존의 테스트 케이스에 혹은 새로 구성하여 반영해줍니다.

b.N 만큼 SumNumbers를 호출하여 성능을 평가한 뒤 결과로 알려주는데, b.N의 값은 본 코드를 쫒아가면 다음 주석이 있습니다. **Run the benchmark for at least the specified amount of time.**

테스트를 수행하는 환경에서 benchmark를 수행하기 위한 적당한 시간 및 횟수를 계산하고 그를 기준으로 benchmark 테스트를 합니다.

**실행 방법**

```go
go test -bench=. #(테스트 코드 경로)
```

**실행 결과**

```go
BenchmarkSumNumbers-12          361147497                3.295 ns/op
PASS
ok      test    1.534s
```

수행 결과로 361147497번의 호출을 했을때 평균 3.295 ns의 시간이 걸리는 것을 확인할 수 있습니다.

위 내용중에 b.N에 대해 아직 모호하게 생각되는 분들을 위해 아래 두 옵션을 추가로 소개해드립니다.

benchtime 옵션을 통해 시간 혹은 횟수를 지정하여 테스트할 수 있습니다.

**명시적 횟수 지정 예 (10회)**

```go
go test -bench=. -benchtime=100x
```

**명시적 시간 지정 예 (10초)**

```go
go test -bench=. -benchtime=10s
```

위 옵션으로 몇가지를 테스트 해보겠습니다.

1. 명시적 횟수에 따른 벤치마크 테스트 (수행 시간을 주목해주세요)

```go
go test -bench=. -benchtime=1x
BenchmarkSumNumbers-12                 1               246.0 ns/op

go test -bench=. -benchtime=10x
BenchmarkSumNumbers-12                10                25.40 ns/op

go test -bench=. -benchtime=100x
BenchmarkSumNumbers-12               100                 9.610 ns/op

go test -bench=. -benchtime=1000x
BenchmarkSumNumbers-12              1000                 4.072 ns/op

go test -bench=. -benchtime=100000x
BenchmarkSumNumbers-12            100000                 4.096 ns/op

go test -bench=. -benchtime=100000000x
BenchmarkSumNumbers-12          100000000                3.403 ns/op

go test -bench=. -benchtime=1000000000x
BenchmarkSumNumbers-12          1000000000               3.309 ns/op
```

benchmark 수행 횟수가 적을 수록 평균 시간이 엄청 느린 것을 알 수 있습니다. 1~1000회까지는 속도의 차이가 꽤 심하며, 그 이후로는 큰 차이를 보이지 않는것도 확인할 수 있네요.

수행 횟수에 따라 시간이 달라지는걸 예상해보면, 컴파일 이후 loader로 부터 메모리에 fetch 되고 실행 되는 과정이 한번 수행할때는 크게 영향을 주고, 많이 수행할땐 그 수로 나눠지면서 미미해지는게 아닌가 싶습니다.

예를들면 아래와 같습니다.

1회일 경우: (메모리 올라가는 시간 + 1번 수행 시간) / 1

100회일 경우: (메모리 올라가는 시간 + 100번 수행 시간) / 100

위 계산 방식으로 다항식을 실제 결과와 비교해보니 딱 들어맞지는 않습니다. 메모리에 올라가는 시간 말고 다른 영향을 미치는 부분이 있나봅니다.

2. 명시적 시간 지정에 따른 벤치마크 테스트 (수행 횟수를 주목해주세요)

```go
go test -bench=. -benchtime=0.001s
BenchmarkSumNumbers-12            290641                 3.964 ns/op

go test -bench=. -benchtime=0.01s
BenchmarkSumNumbers-12           3124398                 3.924 ns/op

go test -bench=. -benchtime=0.1s
BenchmarkSumNumbers-12          30180873                 3.577 ns/op

go test -bench=. -benchtime=1s
BenchmarkSumNumbers-12          350010990                3.399 ns/op

go test -bench=. -benchtime=2s
BenchmarkSumNumbers-12          706296723                3.319 ns/op

go test -bench=. -benchtime=3s
BenchmarkSumNumbers-12          1000000000               3.313 ns/op

go test -bench=. -benchtime=4s
BenchmarkSumNumbers-12          1000000000               3.310 ns/op
```

n초에 시행할 수 있는 횟수를 계산해서 benchmark를 수행해주는데, 재밌는건 2초까지는 횟수가 늘다가 3초부턴 상한 값이 정해져있는지 혹은 그이상 의미가 없는지 더 늘어나지 않는 모습을 알 수 있습니다.

정리해보면 benchmark에 별도로 benchtime 옵션을 주지 않으면 컴퓨터 환경에 따라 golang에서 알아서 계산 후 수행합니다. 혹시 benchmark 수행을 매번 돌리실 경우나 정확한 성능평가보단 추세를 보고싶으시다면 적당한 크기 (위 예제에선 1000 회 정도)로 지정해도 괜찮을 것 같네요.

# 3. 정리

비교적 간단한 내용이고 이미 공식 블로그나 다른 곳에서도 정리된 글들이 많이 보여서 글로 정리할 필요가 있을까 고민을 조금 했습니다. 하지만 중간 중간 궁금한 내용들을 찾아보고 그 부분만을 기록으로 남기면 누군가가 보았을때 그 흐름을 알지 못할수도 있겠다고 생각했습니다. 그리고 이 글을 계속 덧붙여 업데이트 해나갈 기준을 만들어 두고 싶었던 이유도 있습니다. 테스트와 관련해서는 앞으로도 꾸준히 글과 생각을 정리해서 올려보려고 합니다.

# 참고자료

[https://golang.org/pkg/testing/](https://golang.org/pkg/testing/)

[https://blog.golang.org/cover](https://blog.golang.org/cover)
