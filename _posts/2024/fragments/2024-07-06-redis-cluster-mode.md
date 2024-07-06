---
title: "-"
layout: single
author_profile: false
read_time: true
share: true
related: true
categories:
  - Daily
tags:
  - Blog
toc: false
toc_stiky: true
description: ""
article_section: ""
meta_keywords: ""
last_modified_at: '"2024-06-30 09:00:00 +0800"'
---
redis cluster mode에 대해 이해하고, 현재 구성된 redis 환경 정보를 확인하는 방법에 대해 알아봅니다.

## What is Cluster Mode?
> Redis 클러스터는 단순히 [데이터 분할 전략 입니다.](https://www.digitalocean.com/community/tutorials/understanding-database-sharding). 여러 Redis 노드에 걸쳐 데이터를 자동으로 분할합니다.

Redis는 주노드(Primary node)와 복제 노드(Replica Node)로 구성하는 것이 일반적이며, 이런 구성을 shard
로 여러 벌 준비하여 data partinioning을 수행하는 것이 클러스터 모드(cluster mode) 입니다.
샤딩으로 데이터는 수평분할 어 저장됨에 따라 scale out, 단일 장애 지점(SPOF) 개선, 성능 향상 등의 이점을 얻을 수 있습니다.

![[Pasted image 20240706161619.png]]
(출처: https://aws.amazon.com/ko/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/)
![[Pasted image 20240706161646.png]]
(출처: https://ot-container-kit.github.io/redis-operator/guide/setup.html?ref=breezymind.com#redis-cluster)![[Pasted image 20240706161857.png]]
(출처: https://aws.amazon.com/ko/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/)

## Cluster Mode 종류
> AWS ElastiCache. But the truth is, ElastiCache isn’t Redis. Instead, it’s a Redis-compatible imitator managed by AWS with limited extra functionality.

(redis cloud 소개 관련 글에서 위와 같이 언급)[https://redis.io/cloud/compare-us-with-aws-elasticache/?utm_campaign=gg_s_competitor_bam_acq_apac-en&utm_source=google&utm_medium=cpc&utm_content=elasticache&utm_term=&gad_source=1&gclid=Cj0KCQjw1qO0BhDwARIsANfnkv9vMuzTeVvGvdHDSbmArIOkrxbHmuqfSoYLVemtJVpzkat8vF5lyNYaAtxzEALw_wcB]하며 차이를 소개하고 있지만 Cluster Mode의 경우 실제 운영 구조가 동일할 것이라고 생각되어 아래와 같이 가져왔습니다.
![[Pasted image 20240706163022.png]]

# redis-cli로 cluster mode 환경 살펴보기
redis-cli를 설치하려면 환경에 맞게 (링크)[https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/] 에서 확인하고 설치해줍니다.

현재 실행된 환경을 확인하는 방법은 다음과 같습니다.

```sh
# Connect to Redis server
$ redis-cli -h 127.0.0.1 -p 6379
# Check if cluster mode is enabled
CONFIG GET cluster-enabled
# Get all configuration settings
CONFIG GET *
# Get cluster nodes information
CLUSTER NODES
# Get cluster info
CLUSTER INFO
```

standalone 모드로 실행한 경우 아래와 같이 표시됩니다.
```
127.0.0.1:6379> CONFIG GET cluster-enabled
1) "cluster-enabled"
2) "no"
```

# Reference
- https://aws.amazon.com/ko/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/
- https://ot-container-kit.github.io/redis-operator/guide/setup.html?ref=breezymind.com#redis-cluster
- https://www.digitalocean.com/community/tutorials/understanding-database-sharding