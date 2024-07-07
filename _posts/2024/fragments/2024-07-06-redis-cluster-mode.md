---
title: redis - cluster mode
layout: single
author_profile: false
read_time: true
share: true
related: true
categories:
  - Redis
tags:
  - Redis
  - Redis-Cluster
toc: false
toc_stiky: true
description: 
article_section: ""
meta_keywords: ""
last_modified_at: 2024-07-07T15:28:11+09:00
created: 2024-07-06T15:10:07+09:00
---
redis cluster mode에 대해 이해하고, 현재 구성된 redis 환경 정보를 확인하는 방법에 대해 알아봅니다.

## What is Cluster Mode?
> redis 클러스터는 단순히 [데이터 분할 전략 입니다.](https://www.digitalocean.com/community/tutorials/understanding-database-sharding) 여러 redis 노드에 걸쳐 데이터를 자동으로 분할합니다.

redis는 주노드(primary node)와 복제 노드(replica node)로 구성하는 것이 일반적이며, 이런 구성을 shard
로 여러 벌 준비하여 data partitioning이 될 수 있는 구성이 클러스터 모드(cluster mode) 입니다.

shading으로 데이터는 수평분할 어 저장됨에 따라 scale out, 단일 장애 지점(SPOF) 개선, 성능 향상 등의 이점을 얻을 수 있으며, 클러스터 구조에 따라 복잡성이 증가할 수 있으므로 상황에 따라 적절한 구조를 선택하는 것이 필요합니다.
![](https://i.imgur.com/435CqKW.png)
(출처:[How to work with Cluster Mode on Amazon ElastiCache for Redis](https://aws.amazon.com/ko/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/))
![](https://i.imgur.com/cQ60lqb.png)aws article [How to work with Cluster Mode on Amazon ElastiCache for Redis](https://aws.amazon.com/ko/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/)에서 다루고 있는 용어와 [redis.io 문서](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/)에서 표현되는 용어가 미묘하게 다르지만, 위 이미지와 같이 비슷한 구조로 나누어 설명하고 있는것을 알 수 있습니다.

## Redis Mode 별 차이 비교
aws article에서 각 mode별 구성에 대해 잘 정리한 표가 있어서 가져왔습니다. 앞서 언급한 내용과 같이 각각의 모드는 redis.io에서 언급하고 있는 standalone, sentienl, cluster mode와 유사한 범주로 언급하고 있음을 알 수 있습니다. 
![](https://i.imgur.com/UKhYAt4.png)
(출처:[How to work with Cluster Mode on Amazon ElastiCache for Redis](https://aws.amazon.com/ko/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/))

수평 확장을 통해 성능상의 이점 등을 얻기 위해선 결국 data partitioning을 통한 sharding이 되어야 하는데, redis의 경우 hashslot을 통해 파티셔닝을 처리하는 것을 아래 그림에서 설명하고 있습니다.
![](https://i.imgur.com/PwcCqGW.png)
(출처:[How to work with Cluster Mode on Amazon ElastiCache for Redis](https://aws.amazon.com/ko/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/))

따라서 aws managed 서비스인 elastiCache를 사용하든 별도로 구성된 cluster mode를 사용하든 현재 구성된 클러스터 구조를 확인하고 이해하고 있어야 sharding을 통해 얻을수 있는 이점과, 관리 포인트를 이해하고 주의할 수 있을 것 입니다.

# redis-cli로 cluster mode 환경 살펴보기
redis-cli를 설치하려면 환경에 맞게 [링크](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/) 에서 확인하고 설치해줍니다.

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

aws elastiCache로 redis cluster를 구성한 경우 아래와 같은 방법으로 정보를 확인할 수 있습니다.
```
xxx.cache.amazonaws.com:6379> CLUSTER INFO
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:2
cluster_size:1
...
```

```
xxx.cache.amazonaws.com:6379> CLUSTER NODES
{slave-node-id} 192.168.xxx.xxx:6379@1122 slave {master-node-id} 0 1720327133306 5 connected
{master-node-id} 192.168.xxx.xxx:6379@1122 myself,master - 0 1700412779000 5 connected 0-16383
```

# References
- https://aws.amazon.com/ko/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/
- https://ot-container-kit.github.io/redis-operator/guide/setup.html?ref=breezymind.com#redis-cluster
- https://www.digitalocean.com/community/tutorials/understanding-database-sharding
