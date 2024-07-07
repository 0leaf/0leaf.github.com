---
title: go-redis - go-redis v9 에서 hash 타입을 다루는 방법
layout: single
author_profile: false
read_time: true
share: true
related: true
categories:
  - Redis
tags:
  - Redis
  - Go-redis
toc: false
toc_stiky: true
description: ""
article_section: ""
meta_keywords: ""
completed: false
visible: 
status: 
created: 2024-06-30T19:08
last_modified_at: 2024-07-07T18:15:23+09:00
thumnail_url: 
priority: 
---
# TL;DR
- go-reds v9 버전부터 
	- hashset을 저장할때 interface로 전달하지 않고 type 을 전달해도 저장됩니다.
	- 역직렬화 과정에서도 scan을 통해 HGetAll, MGet 등을 type으로 unmarshal 할 수 있습니다.
# Overview
go-redis/v9 버전 이상에서 사용 가능한 기능들을 발견하여, 용례를 정리하고 성능 등 문제가 없는지 비교해봅니다.
## Usage
### go-redis/v8 이하
- HashSet
	- map interface를 만들어서 저장해야 한다.
	- type을 만들어서 전달할 경우 아래의 에러 메세지를 받는다.
		- `redis: can't marshal main.User (implement encoding.BinaryMarshaler)`
```go

func populateDataV8(rdb *redisv8.Client, n int) {
	for i := 1; i <= n; i++ {
		user := User{
			Name:    fmt.Sprintf("User%d", i),
			Age:     20 + (i % 30),
			Email:   fmt.Sprintf("user%d@example.com", i),
			Country: "Country" + strconv.Itoa(i%10),
		}

		userMap := map[string]interface{}{
			"name":    user.Name,
			"age":     user.Age,
			"email":   user.Email,
			"country": user.Country,
		}

		err := rdb.HSet(ctx, fmt.Sprintf("user:%d", i), userMap).Err()
		if err != nil {
			log.Fatalf("Failed to set user %d: %v", i, err)
		}
	}
}

```

- HGetAll
	- map interface로 전달받은 값을 map을 참조하여 결과를 구성
```go
func fetchDataV8(rdb *redisv8.Client, n int) {
	for i := 1; i <= n; i++ {
		fields, err := rdb.HGetAll(ctx, fmt.Sprintf("user:%d", i)).Result()
		if err != nil {
			log.Fatalf("Failed to get user %d: %v", i, err)
		}

		var user User
		user.Name = fields["name"]
		user.Age, _ = strconv.Atoi(fields["age"])
		user.Email = fields["email"]
		user.Country = fields["country"]
		// Print for debug purpose, comment out during benchmarking
		// fmt.Printf("user:%d - %+v\n", i, user)
	}
}

```


### go-redis/v9 이상
- HashSet
	- type으로 생성된 결과를 그대로 전달해도 저장된다.
	- string, int 여러 타입이 섞여 전달 될 수 있다.
```go
	for i := 1; i <= n; i++ {
		user := User{
			Name:    fmt.Sprintf("User%d", i),
			Age:     20 + (i % 30),
			Email:   fmt.Sprintf("user%d@example.com", i),
			Country: "Country" + strconv.Itoa(i%10),
		}

		err := rdb.HSet(ctx, fmt.Sprintf("user:%d", i), user).Err()
		if err != nil {
			log.Fatalf("Failed to set user %d: %v", i, err)
		}
	}

```
- HGetAll
	- Scan 을 통해 타입에 맞도록 결과를 unmarshal 한다.
```go

func fetchDataV9(rdb *redisv9.Client, n int) {
	for i := 1; i <= n; i++ {
		res := rdb.HGetAll(ctx, fmt.Sprintf("user:%d", i))

		var user User
		if err := res.Scan(&user); err != nil {
			log.Fatalf("Failed to get user %d: %v", i, err)
		}
		// Print for debug purpose, comment out during benchmarking
		// fmt.Printf("user:%d - %+v\n", i, user)
	}
}

```





### Benchmark
- go-redis v8, v9의 hash저장, 조회 관련된 operation 을 수행하는 동작을 테스트한 결과는 아래와 같습니다.
- v9이 v8에 비해 성능면에서는 다소 느려진 점이 있으나, 무시해도 될만한 수준의 차이입니다.
```go
=== RUN   BenchmarkPopulateDataV8
BenchmarkPopulateDataV8
BenchmarkPopulateDataV8-10            20          57818098 ns/op           99482 B/op       2010 allocs/op
=== RUN   BenchmarkPopulateDataV9
BenchmarkPopulateDataV9
BenchmarkPopulateDataV9-10            21          67450760 ns/op           69820 B/op       2213 allocs/op
=== RUN   BenchmarkFetchDataV8
BenchmarkFetchDataV8
BenchmarkFetchDataV8-10               18          60724053 ns/op           67652 B/op       1716 allocs/op
=== RUN   BenchmarkFetchDataV9
BenchmarkFetchDataV9
BenchmarkFetchDataV9-10               18          62911891 ns/op           71903 B/op       2030 allocs/op
```

## Conclusion
redis에 데이터를 저장할때, type을 지정해두고 값을 저장, 조회한다면 가독성과 코드 구조가 많이 개선될 수 있을 것 같습니다.
무조건 버전을 올리기보다, 필요한 기능으로 적용이 필요할때 올리면 좋을 것 같습니다.
# References
- [https://github.com/redis/go-redis/issues/672](https://github.com/redis/go-redis/issues/672)
- https://github.com/redis/go-redis/blob/f8cbf483f4a193d441fac2cf14be3d84783848c6/example_test.go#L281
- https://github.com/redis/go-redis/discussions/2454
- https://github.com/redis/go-redis